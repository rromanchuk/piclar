

#import "PhotoNewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extensions.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceSearchViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "FilterButtonView.h"
#import "CheckinCreateViewController.h"
#import "Place+Rest.h"
#import "UIImage+Resize.h"
#import "Utils.h"
#import "MoveAndScalePhotoViewController.h"
@interface PhotoNewViewController ()

@end

@implementation PhotoNewViewController


@synthesize libraryButton;
@synthesize previewImageView;
@synthesize filterScrollView;
@synthesize imageSelectorScrollView;
@synthesize managedObjectContext;
@synthesize toolBar;
@synthesize gpuImageView;
@synthesize filters;
@synthesize camera;
@synthesize selectedFilter;
@synthesize croppedFilter = _croppedFilter;
@synthesize selectedFilterName;
@synthesize imageFromLibrary;
@synthesize croppedImageFromCamera;
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.toolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    }
    
    self.filters = [NSArray arrayWithObjects:@"Normal", @"TiltShift", @"Sepia", @"MissEtikateFilter", @"AmatorkaFilter", @"SoftElegance", nil];
    
    [self setupFilters];
    [self setupInitialCameraState:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[Location sharedLocation].locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setFilterScrollView:nil];
    [self setGpuImageView:nil];
    [self setLibraryButton:nil];
    [self setToolBar:nil];
    [self setImageSelectorScrollView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckinCreate"])
    {
        CheckinCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.filteredImage = self.previewImageView.image;
        vc.place = [Place fetchClosestPlace:[Location sharedLocation] inManagedObjectContext:self.managedObjectContext];
        vc.delegate = self.delegate;
    } else if ([[segue identifier] isEqualToString:@"ScaleAndResize"]) {
        MoveAndScalePhotoViewController *vc = [segue destinationViewController];
        vc.image = self.imageFromLibrary;
        vc.delegate = self;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)rotateCamera:(id)sender {
    [self.camera rotateCamera];
}

- (IBAction)pictureFromLibrary:(id)sender {
    [self.camera stopCameraCapture];
    self.selectedFilter = [self filterWithKey:self.selectedFilterName];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)dismissModal:(id)sender {
    [self.camera stopCameraCapture];
    [self.delegate didFinishCheckingIn];
}

- (IBAction)didTakePicture:(id)sender {
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.croppedFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        DLog(@"Image width: %f height: %f", processedImage.size.width, processedImage.size.height);
        self.croppedImageFromCamera = [processedImage resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
    }];
    [self.camera stopCameraCapture];
    self.previewImageView.image = [((GPUImageFilterGroup *)self.selectedFilter).terminalFilter imageByFilteringImage:self.croppedImageFromCamera];
    [self.gpuImageView setHidden:YES];
    [self.previewImageView setHidden:NO];
    [self acceptOrRejectToolbar];
    //    [self.camera capturePhotoAsImageProcessedUpToFilter:self.selectedFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
//        //NSData *dataForPNGFile = UIImageJPEGRepresentation(processedImage, 0.8);
//        //float size = [Utils sizeForDevice:640.0];
//        DLog(@"Image width: %f height: %f", processedImage.size.width, processedImage.size.height);
//        self.previewImageView.image = [processedImage resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
//        [self.gpuImageView setHidden:YES];
//        [self.previewImageView setHidden:NO];
//        [self acceptOrRejectToolbar];
//    }];
    
}

- (IBAction)setupInitialCameraState:(id)sender {
    // Remove any previous stored images
    self.imageFromLibrary = nil;
    self.croppedImageFromCamera = nil;
    self.previewImageView.image = nil;
    
    // Display video input source
    self.gpuImageView.hidden = NO;
    self.previewImageView.hidden = YES;
    
    self.camera = [[GPUImageStillCamera alloc] init];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    
    self.selectedFilter =  [[GPUImageFilterGroup alloc] init];
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.125, 1.0, 0.75)];
    GPUImageBrightnessFilter *normalFilter = [self filterWithKey:@"Normal"];
    self.croppedFilter = cropFilter;
    [(GPUImageFilterGroup *)self.selectedFilter addFilter:normalFilter];
    [cropFilter addTarget:normalFilter];
    
    [(GPUImageFilterGroup *)self.selectedFilter setInitialFilters:[NSArray arrayWithObjects: cropFilter, nil]];
    [(GPUImageFilterGroup *)self.selectedFilter setTerminalFilter:normalFilter];
    
    
    //self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [self.selectedFilter prepareForImageCapture];
    [self.selectedFilter forceProcessingAtSize:CGSizeMake(640.0, 640.0)];
    [self.camera addTarget:self.selectedFilter];
    [self.selectedFilter addTarget:self.gpuImageView];
    
    [self.camera startCameraCapture];
    [self standardToolbar];
}


- (void)applyFilter {
    if (self.imageFromLibrary) {
        DLog(@"Applying filter to photo from library");
        self.camera.outputImageOrientation = self.imageFromLibrary.imageOrientation;
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.imageFromLibrary];
    } else if (self.croppedImageFromCamera) {
        DLog(@"Applying filter to photo from camera");
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.croppedImageFromCamera];
    }
}

- (IBAction)didChangeFilter:(id)sender {
    DLog(@"didChangeFilter called");
    NSString *filterName = ((FilterButtonView *)sender).filterName;
    
    if(filterName != self.selectedFilterName) {
        [self.camera removeAllTargets];
        [self.selectedFilter removeAllTargets];
        self.selectedFilterName = filterName;
        if(self.imageFromLibrary || self.croppedImageFromCamera){
            DLog(@"Changing filter to %@ and applying", filterName);
            self.selectedFilter = [self filterWithKey:filterName];
            [self.selectedFilter prepareForImageCapture];
            [self applyFilter];
        } else {
            
            self.selectedFilter =  [[GPUImageFilterGroup alloc] init];
            GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.125, 1.0, 0.75)];
            GPUImageFilter *newFilter = [self filterWithKey:filterName];
            self.croppedFilter = cropFilter;
            
            [(GPUImageFilterGroup *)self.selectedFilter addFilter:newFilter];
            [cropFilter addTarget:newFilter];
            
            [(GPUImageFilterGroup *)self.selectedFilter setInitialFilters:[NSArray arrayWithObjects: cropFilter, nil]];
            [(GPUImageFilterGroup *)self.selectedFilter setTerminalFilter:newFilter];
            
            //self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            [self.selectedFilter prepareForImageCapture];
            [self.camera addTarget:self.selectedFilter];
            [self.selectedFilter addTarget:self.gpuImageView];
            [self.selectedFilter forceProcessingAtSize:CGSizeMake(640.0, 640.0)];
        }
    }
}

- (IBAction)didSave:(id)sender {
    [self performSegueWithIdentifier:@"CheckinCreate" sender:self];
}

- (IBAction)didHideFilters:(id)sender {
    //self.camera.inputCamera setFlashMode:AVCAPTUREF
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:NO];
    DLog(@"Coming back with image");
    imageIsFromLibrary = YES;
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    DLog(@"Size of image is height: %f, width: %f", image.size.height, image.size.width);
   
    self.imageFromLibrary = image;
    // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    if (image.size.width < 640.0 && image.size.height < 640.0) {
        // The image is so small it doesn't need to be resized, this isn't great because it will forcefully scaled up.
        [self didFinishPickingFromLibrary:self];
    } else {
        // This image needs to be scaled and cropped into a square image
        [self performSegueWithIdentifier:@"ScaleAndResize" sender:self];
    }
    
}
- (IBAction)didFinishPickingFromLibrary:(id)sender {
    [self applyFilter];
    [self.gpuImageView setHidden:YES];
    [self.previewImageView setHidden:NO];
    [self acceptOrRejectToolbar];

}
- (void)acceptOrRejectToolbar {
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *acceptPhoto = [UIImage imageNamed:@"photo-accept.png"];
    UIImage *rejectPhoto = [UIImage imageNamed:@"photo-reject.png"];
    UIImage *dismissPhoto = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    UIBarButtonItem *accept = [UIBarButtonItem barItemWithImage:acceptPhoto target:self action:@selector(didSave:)];
    UIBarButtonItem *reject = [UIBarButtonItem barItemWithImage:rejectPhoto target:self action:@selector(setupInitialCameraState:)];
    UIBarButtonItem *dismiss = [UIBarButtonItem barItemWithImage:dismissPhoto target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 90;
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, reject, accept, fixed, dismiss, nil];
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
    for (NSString *filter in self.filters) {
        FilterButtonView *filterButton = [FilterButtonView buttonWithType:UIButtonTypeCustom];
        filterButton.frame = CGRectMake(offsetX, 5.0, 50.0, 50.0);
        filterButton.filterName = filter;
        [filterButton setImage:[UIImage imageNamed:@"filters-sample.png"] forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(didChangeFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self.filterScrollView addSubview:filterButton];
        
        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(offsetX, filterButton.frame.size.height + 8, filterButton.frame.size.width, 10.0)];
        filterNameLabel.text = filter;
        filterNameLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
        filterNameLabel.textAlignment = UITextAlignmentCenter;
        filterNameLabel.backgroundColor = [UIColor clearColor];
        filterNameLabel.textColor = [UIColor whiteColor];
        [self.filterScrollView addSubview:filterNameLabel];
        offsetX += 10 + filterButton.frame.size.width;
    }
    //self.filterScrollView.backgroundColor = [UIColor blueColor];
    [self.filterScrollView setContentSize:CGSizeMake(offsetX, 70)];
}

- (GPUImageFilter *)filterWithKey:(NSString *)key {
    GPUImageFilter *filter;
    if (key == @"Normal") {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }else if (key == @"TiltShift") {
        filter = [[GPUImageTiltShiftFilter alloc] init];
    }else if(key == @"Sepia") {
        filter = [[GPUImageSepiaFilter alloc] init];
    } else if(key == @"MissEtikateFilter") {
        filter = [[GPUImageMissEtikateFilter alloc] init];
    } else if (key == @"AmatorkaFilter") {
        filter = [[GPUImageAmatorkaFilter alloc] init];
    } else if (key == @"SoftElegance") {
        filter = [[GPUImageSoftEleganceFilter alloc] init];
    }
    else {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }
    return filter;
}

- (void)didGetLocation
{
    DLog(@"PlaceSearch#didGetLocation with accuracy %f", [Location sharedLocation].locationManager.location.horizontalAccuracy);
    
    // If our accuracy is poor, keep trying to improve
#warning Sometimes accuracy wont ever get better and this causes a constant updating which is not energy effiecient, we should give up after x tries
    if ([Location sharedLocation].locationManager.location.horizontalAccuracy > 100.0) {
        [[Location sharedLocation] update];
    }
}

#warning handle this case better
- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"PlaceSearch#failedToGetLocation: %@", error);
    //lets try again
    [[Location sharedLocation] update];
}


- (void)didResizeImage:(UIImage *)image {
    DLog(@"Size of image is height: %f, width: %f", image.size.height, image.size.width);
    self.imageFromLibrary = image;
    [self dismissModalViewControllerAnimated:YES];
    [self didFinishPickingFromLibrary:self];
}

- (void)didCancelResizeImage {
    [self dismissModalViewControllerAnimated:YES];
}

@end
