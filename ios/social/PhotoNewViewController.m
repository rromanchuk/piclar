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
#import "FilterImageView.h"
@interface PhotoNewViewController ()

@end

@implementation PhotoNewViewController

static const int FILTER_LABEL = 001; 

@synthesize libraryButton;
@synthesize selectedImageView;
@synthesize selectedImage;
@synthesize filteredImage;
@synthesize filterScrollView;
@synthesize managedObjectContext;
@synthesize toolBar;
@synthesize gpuImageView;
@synthesize filters;
@synthesize camera;
@synthesize selectedFilter;
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
    self.filters = [NSDictionary dictionaryWithObjectsAndKeys:[[GPUImageTiltShiftFilter alloc] init], @"TiltShift", [[GPUImageKuwaharaFilter alloc] init], @"Kuwahara", [[GPUImageSepiaFilter alloc] init], @"Sepia", [[GPUImageToonFilter alloc] init], @"Toon", [[GPUImageGrayscaleFilter alloc] init], @"Grayscale", nil];
    [self setupFilters];
    self.camera = [[GPUImageStillCamera alloc] init];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.selectedFilter = [[GPUImageSketchFilter alloc] init];
    [self.selectedFilter prepareForImageCapture];
    [self.camera addTarget:self.selectedFilter];
    [self.selectedFilter addTarget:self.gpuImageView];
    
        
    [self.camera startCameraCapture];
    
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *takePicturePhoto = [UIImage imageNamed:@"camera.png"];
    UIImage *dismissPhoto = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    UIBarButtonItem *takePicture = [UIBarButtonItem barItemWithImage:takePicturePhoto target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *dismiss = [UIBarButtonItem barItemWithImage:dismissPhoto target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 105;
    self.libraryButton = fromLibrary; 
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, takePicture, fixed, dismiss, nil];
    //[self initializeFilterContext];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
//    if(!fromLibrary)
//        [self takePicture:self];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setSelectedImage:nil];
    [self setFilterScrollView:nil];
    [self setGpuImageView:nil];
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


-(void) applyGesturesToFilterPreviewImageView:(UIView *) view 
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1; 
    
    [view addGestureRecognizer:singleTapGestureRecognizer];        
}


//-(void) applyFilter:(id) sender 
//{
//    selectedFilterView.layer.shadowRadius = 0.0f; 
//    selectedFilterView.layer.shadowOpacity = 0.0f;
//    
//    selectedFilterView = [(UITapGestureRecognizer *) sender view];
//    
//    selectedFilterView.layer.shadowColor = [UIColor yellowColor].CGColor;
//    selectedFilterView.layer.shadowRadius = 3.0f; 
//    selectedFilterView.layer.shadowOpacity = 0.9f;
//    selectedFilterView.layer.shadowOffset = CGSizeZero;
//    selectedFilterView.layer.masksToBounds = NO;
//    
//    int filterIndex = selectedFilterView.tag; 
//    Filter *filter = [filters objectAtIndex:filterIndex];
//    
//    CIImage *outputImage = [filter.filter outputImage];
//    
//    CGImageRef cgimg = 
//    [context createCGImage:outputImage fromRect:[outputImage extent]];
//    
//    finalImage = [UIImage imageWithCGImage:cgimg];
//    
//    finalImage = [finalImage imageRotatedByDegrees:90];  
//    
//    [self.selectedImage setImage:finalImage];
//    
//    CGImageRelease(cgimg);
//    
//}

//-(void) createPreviewViewsForFilters
//{
//    int offsetX = 10; 
//    
//    for(int index = 0; index < [filters count]; index++)
//    {
//        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
//        
//        
//        filterView.tag = index; 
//        
//        // create a label to display the name 
//        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterView.bounds.size.width, 8)];
//        
//        filterNameLabel.center = CGPointMake(filterView.bounds.size.width/2, filterView.bounds.size.height + filterNameLabel.bounds.size.height); 
//        
//        Filter *filter = (Filter *) [filters objectAtIndex:index];
//        
//        filterNameLabel.text =  filter.name;
//        filterNameLabel.backgroundColor = [UIColor clearColor];
//        filterNameLabel.textColor = [UIColor whiteColor];
//        filterNameLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:10];
//        filterNameLabel.textAlignment = UITextAlignmentCenter;
//        
//        CIImage *outputImage = [filter.filter outputImage];
//        
//        CGImageRef cgimg = 
//        [context createCGImage:outputImage fromRect:[outputImage extent]];
//        
//        UIImage *smallImage =  [UIImage imageWithCGImage:cgimg];
//        
//        if(smallImage.imageOrientation == UIImageOrientationUp) 
//        {
//            smallImage = [smallImage imageRotatedByDegrees:90];
//        }
//        
//        // create filter preview image views 
//        UIImageView *filterPreviewImageView = [[UIImageView alloc] initWithImage:smallImage];
//        
//        [filterView setUserInteractionEnabled:YES];
//        
//        filterPreviewImageView.layer.cornerRadius = 15;  
//        filterPreviewImageView.opaque = NO;
//        filterPreviewImageView.backgroundColor = [UIColor clearColor];
//        filterPreviewImageView.layer.masksToBounds = YES;        
//        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60); 
//        
//        filterView.tag = index; 
//        
//        [self applyGesturesToFilterPreviewImageView:filterView];
//        
//        [filterView addSubview:filterPreviewImageView];
//        [filterView addSubview:filterNameLabel];
//        
//        [self.filterScrollView addSubview:filterView];
//        
//        offsetX += filterView.bounds.size.width + 10;
//        
//    }
//    
//    [self.filterScrollView setContentSize:CGSizeMake(400, 90)]; 
//}

//-(void) loadFiltersForImage:(UIImage *) image
//{
//    
//    CIImage *filterPreviewImage = [[CIImage alloc] initWithImage:image]; 
//    
//    CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,filterPreviewImage,
//                             @"inputIntensity",[NSNumber numberWithFloat:0.8],nil];
//    
//    
//    CIFilter *colorMonochrome = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,filterPreviewImage,
//                                 @"inputColor",[CIColor colorWithString:@"Red"],
//                                 @"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
//    
//    filters = [[NSMutableArray alloc] init];
//    
//    
//    [filters addObjectsFromArray:[NSArray arrayWithObjects:
//                                  [[Filter alloc] initWithNameAndFilter:@"Sepia" filter:sepiaFilter],
//                                  [[Filter alloc] initWithNameAndFilter:@"Mono" filter:colorMonochrome]
//                                  
//                                  , nil]];
//    
//    
//    [self createPreviewViewsForFilters];
//}


- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];        
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else 
    {
        fromLibrary = YES;
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)pictureFromLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)dismissModal:(id)sender {
    NSLog(@"DISMISSING MODAL");
    [self.camera stopCameraCapture];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissModal" object:self];
}

- (IBAction)didTakePicture:(id)sender {
    [self.camera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        //NSData *dataForPNGFile = UIImageJPEGRepresentation(processedImage, 0.8);
        self.selectedImage = processedImage;
        self.filteredImage = processedImage;
        [self.gpuImageView setHidden:YES];
        [self.selectedImageView setHidden:NO];
        [self acceptOrRejectToolbar];
        [self.selectedImageView setImage:self.filteredImage];
    }];
}
- (IBAction)didSelectFromLibrary:(id)sender {
    [self.camera stopCameraCapture];
    [self.gpuImageView setHidden:YES];
    [self.selectedImageView setHidden:NO];
    [self acceptOrRejectToolbar];
    [self applyFilter:@"TiltShift"];
    [self.selectedImageView setImage:self.filteredImage];
}

- (IBAction)didCancelOrRejectPicture:(id)sender {
    [self.camera startCameraCapture];
    [self.gpuImageView setHidden:NO];
    [self.selectedImageView setHidden:YES];
    [self standardToolbar];
    [self applyFilter:@"TiltShift"];
    [self.selectedImageView setImage:self.filteredImage];
}


- (void)applyFilter:(NSString *)filterName {
    GPUImageFilter *selectedFilter = [self.filters objectForKey:filterName];
    NSLog(@"FILTERS ARE: %@ FILTER IS: %@", self.filters, selectedFilter);
    self.filteredImage = [selectedFilter imageByFilteringImage:self.selectedImage]; 
}


- (IBAction)didSave:(id)sender {
    [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
}

- (IBAction)didHideFilters:(id)sender {

}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Coming back with image");
    finalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.selectedImage = finalImage;
    [self.selectedImageView setImage:self.selectedImage];
    // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    
    [self dismissModalViewControllerAnimated:YES];
    
    // load the filters again 
    
    //[self loadFiltersForImage:finalImage];
    fromLibrary = NO;
    [self didSelectFromLibrary:self];
}

- (void)acceptOrRejectToolbar {
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *acceptPhoto = [UIImage imageNamed:@"photo-accept.png"];
    UIImage *rejectPhoto = [UIImage imageNamed:@"photo-reject.png"];
    UIImage *dismissPhoto = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    UIBarButtonItem *accept = [UIBarButtonItem barItemWithImage:acceptPhoto target:self action:@selector(didSave:)];
    UIBarButtonItem *reject = [UIBarButtonItem barItemWithImage:rejectPhoto target:self action:@selector(dismissModal:)];
    UIBarButtonItem *dismiss = [UIBarButtonItem barItemWithImage:dismissPhoto target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 90;
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, accept, reject, fixed, dismiss, nil];
}

- (void)standardToolbar {
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *takePicturePhoto = [UIImage imageNamed:@"camera.png"];
    UIImage *dismissPhoto = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    UIBarButtonItem *takePicture = [UIBarButtonItem barItemWithImage:takePicturePhoto target:self action:@selector(didTakePicture:)];
    UIBarButtonItem *dismiss = [UIBarButtonItem barItemWithImage:dismissPhoto target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 105;
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, takePicture, fixed, dismiss, nil];
}

- (void)setupFilters {
    int offsetX = 10;
    for (NSString *filter in [self.filters keyEnumerator]) {
        FilterImageView *filterImageView = [[FilterImageView alloc] initWithFrame:CGRectMake(offsetX, 5.0, 50.0, 50.0)];
        filterImageView.backgroundColor = [UIColor blackColor];
        filterImageView.filterName = filter;
        [self.filterScrollView addSubview:filterImageView];
        offsetX += 10 + filterImageView.frame.size.width;
    }
    [self.filterScrollView setContentSize:CGSizeMake(offsetX, self.filterScrollView.frame.size.height)];
}


@end
