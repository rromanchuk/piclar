//
//  MoveAndScalePhotoViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/20/12.
//
//

#import "MoveAndScalePhotoViewController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
@interface MoveAndScalePhotoViewController ()

@end

@implementation MoveAndScalePhotoViewController
@synthesize image;
@synthesize cancelUiBarButtonItem;
@synthesize chooseUiBarButtonItem;
@synthesize footerTitleLabel;
@synthesize scrollView;
@synthesize imageFromLibrary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.imageFromLibrary setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.image.size.width, self.image.size.height)];
    self.imageFromLibrary.image = self.image;
    [self.scrollView setContentSize:self.image.size];
    [self.scrollView.layer setBorderWidth:1.0];
    [self.scrollView.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [self.cancelUiBarButtonItem setTitle:NSLocalizedString(@"CANCEL", "Cancel editing")];
    [self.chooseUiBarButtonItem setTitle:NSLocalizedString(@"DONE", "Done editing")];
    self.footerTitleLabel.text = NSLocalizedString(@"MOVE_AND_SIZE", "Adust image position and scale");
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setImageFromLibrary:nil];
    [self setScrollView:nil];
    [self setCancelUiBarButtonItem:nil];
    [self setChooseUiBarButtonItem:nil];
    [self setFooterTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didAcceptChanges:(id)sender {
    CGRect visibleRect;
    visibleRect.origin = self.scrollView.contentOffset;
    visibleRect.size = self.scrollView.bounds.size;
    
    float theScale = 1.0 / self.scrollView.zoomScale;
    visibleRect.origin.x *= theScale;
    visibleRect.origin.y *= theScale;
    visibleRect.size.width *= theScale;
    visibleRect.size.height *= theScale;
    UIImage *croppedImaged = [self.imageFromLibrary.image croppedImage:visibleRect];
    //croppedImaged
    croppedImaged = [croppedImaged resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];
    [self.delegate didResizeImage:croppedImaged];
}

- (IBAction)didCancel:(id)sender {
    [self.delegate didCancelResizeImage];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageFromLibrary;
}


@end
