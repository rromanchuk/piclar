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
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 170, 21.0f)];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:RGBACOLOR(242.0, 95.0, 144.0, 1.0)];
    [title setText:NSLocalizedString(@"MOVE_AND_SIZE", "Adust image position and scale")];
    [title setTextAlignment:UITextAlignmentCenter];
    title.adjustsFontSizeToFitWidth = YES;
    title.backgroundColor = [UIColor yellowColor];
    
    UIBarButtonItem *footerTitle = [[UIBarButtonItem alloc] initWithCustomView:title];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL", "Cancel editing") style:UIBarButtonItemStyleBordered target:self action:@selector(didCancel:)];
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", "Done editing") style:UIBarButtonItemStyleBordered target:self action:@selector(didAcceptChanges:)];
    
    self.toolbar.items = [NSArray arrayWithObjects:cancel, footerTitle, confirm, nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"SCREEN_MOVE_AND_RESIZE"];
}

- (void)viewDidUnload
{
    [self setImageFromLibrary:nil];
    [self setScrollView:nil];
    [self setCancelUiBarButtonItem:nil];
    [self setChooseUiBarButtonItem:nil];
    [self setToolbar:nil];
    [self setFooterTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didAcceptChanges:(id)sender {
    CGRect visibleRect;
    visibleRect.origin = CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - 44);
    visibleRect.size = CGSizeMake(320, 320);
    
    DLog(@"x: %f y: %f  width: %f height: %f", visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height);
    
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
