//
//  PhotoNewViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoNewViewController.h"
#import "Filter.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extensions.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceSearchViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "NewPhotoToolBar.h"
@interface PhotoNewViewController ()

@end

@implementation PhotoNewViewController

static const int FILTER_LABEL = 001; 

@synthesize saveButton;
@synthesize selectedImage;
@synthesize filterScrollView;
@synthesize managedObjectContext;
@synthesize toolBar;


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
    if ([self.toolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    }
    
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *takePicturePhoto = [UIImage imageNamed:@"camera.png"];
    UIImage *takeVideoPhoto = [UIImage imageNamed:@"video.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *takePicture = [UIBarButtonItem barItemWithImage:takePicturePhoto target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *takeVideo = [UIBarButtonItem barItemWithImage:takeVideoPhoto target:self action:@selector(didSelectSettings:)];
    
    NewPhotoToolBar *customToolbar = (NewPhotoToolBar *) self.toolBar;
    ((NewPhotoToolBar * )self.toolBar).fromLibrary = fromLibrary;
    customToolbar.fromLibrary = fromLibrary; 
    customToolbar.takePicture = takePicture; 
    customToolbar.takeVideo = takeVideo;
    
    [self initializeFilterContext];
    [self takePicture:self];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setSelectedImage:nil];
    [self setFilterScrollView:nil];
    [self setSaveButton:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceSearch"])
    {
        PlaceSearchViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)initializeFilterContext 
{
    context = [CIContext contextWithOptions:nil];
}

-(void) applyGesturesToFilterPreviewImageView:(UIView *) view 
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1; 
    
    [view addGestureRecognizer:singleTapGestureRecognizer];        
}


-(void) applyFilter:(id) sender 
{
    selectedFilterView.layer.shadowRadius = 0.0f; 
    selectedFilterView.layer.shadowOpacity = 0.0f;
    
    selectedFilterView = [(UITapGestureRecognizer *) sender view];
    
    selectedFilterView.layer.shadowColor = [UIColor yellowColor].CGColor;
    selectedFilterView.layer.shadowRadius = 3.0f; 
    selectedFilterView.layer.shadowOpacity = 0.9f;
    selectedFilterView.layer.shadowOffset = CGSizeZero;
    selectedFilterView.layer.masksToBounds = NO;
    
    int filterIndex = selectedFilterView.tag; 
    Filter *filter = [filters objectAtIndex:filterIndex];
    
    CIImage *outputImage = [filter.filter outputImage];
    
    CGImageRef cgimg = 
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    finalImage = [UIImage imageWithCGImage:cgimg];
    
    finalImage = [finalImage imageRotatedByDegrees:90];  
    
    [self.selectedImage setImage:finalImage];
    
    CGImageRelease(cgimg);
    
}

-(void) createPreviewViewsForFilters
{
    int offsetX = 10; 
    
    for(int index = 0; index < [filters count]; index++)
    {
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
        
        
        filterView.tag = index; 
        
        // create a label to display the name 
        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterView.bounds.size.width, 8)];
        
        filterNameLabel.center = CGPointMake(filterView.bounds.size.width/2, filterView.bounds.size.height + filterNameLabel.bounds.size.height); 
        
        Filter *filter = (Filter *) [filters objectAtIndex:index];
        
        filterNameLabel.text =  filter.name;
        filterNameLabel.backgroundColor = [UIColor clearColor];
        filterNameLabel.textColor = [UIColor whiteColor];
        filterNameLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:10];
        filterNameLabel.textAlignment = UITextAlignmentCenter;
        
        CIImage *outputImage = [filter.filter outputImage];
        
        CGImageRef cgimg = 
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *smallImage =  [UIImage imageWithCGImage:cgimg];
        
        if(smallImage.imageOrientation == UIImageOrientationUp) 
        {
            smallImage = [smallImage imageRotatedByDegrees:90];
        }
        
        // create filter preview image views 
        UIImageView *filterPreviewImageView = [[UIImageView alloc] initWithImage:smallImage];
        
        [filterView setUserInteractionEnabled:YES];
        
        filterPreviewImageView.layer.cornerRadius = 15;  
        filterPreviewImageView.opaque = NO;
        filterPreviewImageView.backgroundColor = [UIColor clearColor];
        filterPreviewImageView.layer.masksToBounds = YES;        
        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60); 
        
        filterView.tag = index; 
        
        [self applyGesturesToFilterPreviewImageView:filterView];
        
        [filterView addSubview:filterPreviewImageView];
        [filterView addSubview:filterNameLabel];
        
        [self.filterScrollView addSubview:filterView];
        
        offsetX += filterView.bounds.size.width + 10;
        
    }
    
    [self.filterScrollView setContentSize:CGSizeMake(400, 90)]; 
}

-(void) loadFiltersForImage:(UIImage *) image
{
    
    CIImage *filterPreviewImage = [[CIImage alloc] initWithImage:image]; 
    
    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,filterPreviewImage,
                             @"inputIntensity",[NSNumber numberWithFloat:0.8],nil];
    
    
    CIFilter *colorMonochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,filterPreviewImage,
                                 @"inputColor",[CIColor colorWithString:@"Red"],
                                 @"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
    
    filters = [[NSMutableArray alloc] init];
    
    
    [filters addObjectsFromArray:[NSArray arrayWithObjects:
                                  [[Filter alloc] initWithNameAndFilter:@"Sepia" filter:sepiaFilter],
                                  [[Filter alloc] initWithNameAndFilter:@"Mono" filter:colorMonochrome]
                                  
                                  , nil]];
    
    
    [self createPreviewViewsForFilters];
}


- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];        
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else 
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    finalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.selectedImage setImage:finalImage];
    
    // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    [self dismissModalViewControllerAnimated:YES];
    
    // load the filters again 
    
    [self loadFiltersForImage:finalImage];
}



@end
