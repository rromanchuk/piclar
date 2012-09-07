

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
#import "AppDelegate.h"
@interface PhotoNewViewController ()
@property BOOL applicationDidJustStart;
@end

@implementation PhotoNewViewController


@synthesize libraryButton;
@synthesize previewImageView;
@synthesize filterScrollView;
@synthesize flashButton;
@synthesize imageSelectorScrollView;
@synthesize managedObjectContext;
@synthesize toolBar;
@synthesize gpuImageView;
@synthesize filters;

@synthesize camera;
@synthesize selectedFilterButtonView;

@synthesize croppedFilter = _croppedFilter;
@synthesize selectedFilter;

@synthesize selectedFilterName;
@synthesize imageFromLibrary;
@synthesize croppedImageFromCamera;

@synthesize applicationDidJustStart;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [Utils print_free_memory:@"initial memory"];
    if ([self.toolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    }
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).delegate = self;
    self.filters = [NSArray arrayWithObjects:@"Normal", @"TiltShift", @"Sepia", @"MissEtikateFilter", @"AmatorkaFilter", @"Grayscale", @"Sketch", @"Toon", @"Erosion", @"Test", nil];
    
    [Utils print_free_memory:@"before setting up toolbar"];
    [self setupToolbarItems];
    [self setupFilters];
    [Utils print_free_memory:@"After setting up filters"];
    [self setupInitialCameraState:self];
    [Utils print_free_memory:@"after setup filters"];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"IN VIEW DID APPEAR");
    if (self.applicationDidJustStart) {
        DLog(@"APPLICATION DID JUST START");
        [self setupInitialCameraState:self];
        self.applicationDidJustStart = NO;
    }
}

- (void)viewDidUnload
{
    [self setFilterScrollView:nil];
    [self setGpuImageView:nil];
    [self setLibraryButton:nil];
    [self setToolBar:nil];
    [self setImageSelectorScrollView:nil];
    [self setFlashButton:nil];
    [self setCameraControlsView:nil];
    [self setNoFlashButton:nil];
    [self setAutoFlashButton:nil];
    [self setFlashOnButton:nil];
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
    DLog(@"Did take picture");
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APPLYING_FILTER", @"Loading screen as we apply filter")];
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.125, 1.0, 0.75)];
    [self.camera removeAllTargets];
    [self.camera addTarget:cropFilter];
    [cropFilter prepareForImageCapture];
    [Utils print_free_memory:@"Before capturePhoto"];
    [self.camera capturePhotoAsImageProcessedUpToFilter:cropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        [Utils print_free_memory:@"in capture photo"];
        DLog(@"Image width: %f height: %f", processedImage.size.width, processedImage.size.height);
        
        self.croppedImageFromCamera = processedImage;
        //self.previewImageView.image = [[(GPUImageFilterGroup *)self.selectedFilter terminalFilter] imageByFilteringImage:self.croppedImageFromCamera];
        [self.camera stopCameraCapture];
        self.camera = nil;
        //
        
    }];
    [Utils print_free_memory:@"outside block"];
    [self performSelector:@selector(filterOriginalImageAfterBlock) withObject:self afterDelay:4];
   [Utils print_free_memory:@"after selector"];
    //
    //self.gpuImageView = nil;
    
}

- (void)filterOriginalImageAfterBlock {
    [Utils print_free_memory:@"in filter after block"];
    self.croppedImageFromCamera = [self.croppedImageFromCamera resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
    [self.camera removeAllTargets];
    [self.selectedFilter removeAllTargets];
    self.selectedFilter = [self filterWithKey:self.selectedFilterName];
    [self applyFilter];
    UIImageWriteToSavedPhotosAlbum(self.previewImageView.image, self, nil, nil);
    [SVProgressHUD dismiss];
    [self.previewImageView setHidden:NO];
    [self.gpuImageView setHidden:YES];
    [self acceptOrRejectToolbar];
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
    if (!self.camera.inputCamera.hasFlash) {
        self.flashButton.hidden = YES;
    }
    self.selectedFilter =  [[GPUImageFilterGroup alloc] init];
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.125, 1.0, 0.75)];
    self.croppedFilter = cropFilter;
    
    GPUImageFilter *filter; 
    if(self.selectedFilterName.length > 0) {
        filter = [self filterWithKey:self.selectedFilterName];
    } else {
        self.selectedFilterName = @"Normal";
        filter = (GPUImageBrightnessFilter *)[self filterWithKey:self.selectedFilterName];
    }
    
    [(GPUImageFilterGroup *)self.selectedFilter addFilter:filter];
    [cropFilter addTarget:filter];
    
    [(GPUImageFilterGroup *)self.selectedFilter setInitialFilters:[NSArray arrayWithObjects:self.croppedFilter, nil]];
    [(GPUImageFilterGroup *)self.selectedFilter setTerminalFilter:filter];
    
    
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
        //self.camera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.imageFromLibrary];
    } else if (self.croppedImageFromCamera) {
        DLog(@"Applying filter to photo from camera");
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.croppedImageFromCamera];
    }
}

- (IBAction)didChangeFilter:(id)sender {
    FilterButtonView *filterView = (FilterButtonView *)sender;
    NSString *filterName = filterView.filterName;
    [filterView.layer setBorderWidth:1];
    [filterView.layer setBorderColor:RGBCOLOR(242, 95, 144).CGColor];
    [self.selectedFilterButtonView.layer setBorderWidth:0];
    self.selectedFilterButtonView = filterView;
    
    
    DLog(@"didChangeFilter called with %@", filterName);

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
        }
    }
}

- (IBAction)didSave:(id)sender {
    [self performSegueWithIdentifier:@"CheckinCreate" sender:self];
}

- (IBAction)didHideFilters:(id)sender {
    if (self.filterScrollView.hidden) {
        self.filterScrollView.hidden = NO;
    } else {
        self.filterScrollView.hidden = YES;
    }
    
}

- (IBAction)didClickFlash:(id)sender {
    
    if(self.flashButton.selected) {
        self.flashButton.selected =  NO;
        self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = YES;
    } else {
        self.flashButton.selected = YES;
        self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = NO;
    }
    //self.camera.inputCamera setFlashMode:AVCAPTUREF
}

- (IBAction)didSelectFlashOn:(id)sender {
    [self setupInitialCameraState:self];
    [self.camera.inputCamera lockForConfiguration:nil];
    [self.camera.inputCamera setFlashMode:AVCaptureFlashModeOn];
    [self.camera.inputCamera unlockForConfiguration];
    [self didClickFlash:self];
}

- (IBAction)didSelectFlashAuto:(id)sender {
    NSError *error;
    if ([self.camera.inputCamera lockForConfiguration:&error]) {
        [self.camera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
        [self.camera.inputCamera unlockForConfiguration];
    }
    [self didClickFlash:self];

}

- (IBAction)didSelectFlashOff:(id)sender {
    NSError *error;
    if ([self.camera.inputCamera lockForConfiguration:&error]) {
        [self.camera.inputCamera setFlashMode:AVCaptureFlashModeOff];
        [self.camera.inputCamera unlockForConfiguration];
    }
    [self didClickFlash:self];    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [self setupInitialCameraState:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
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

- (void)setupToolbarItems {
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *acceptPhoto = [UIImage imageNamed:@"photo-accept.png"];
    UIImage *rejectPhoto = [UIImage imageNamed:@"photo-reject.png"];
    UIImage *filtersOffPhoto = [UIImage imageNamed:@"switch-filters-off.png"];
    UIImage *filtersOnPhoto = [UIImage imageNamed:@"switch-filters-on.png"];
    UIImage *takePicturePhoto = [UIImage imageNamed:@"camera.png"];
    
    fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    accept = [UIBarButtonItem barItemWithImage:acceptPhoto target:self action:@selector(didSave:)];
    reject = [UIBarButtonItem barItemWithImage:rejectPhoto target:self action:@selector(setupInitialCameraState:)];
    hideFilters = [UIBarButtonItem barItemWithImage:filtersOffPhoto target:self action:@selector(didHideFilters:)];
    showFilters = [UIBarButtonItem barItemWithImage:filtersOnPhoto target:self action:@selector(didHideFilters:)];
    takePicture = [UIBarButtonItem barItemWithImage:takePicturePhoto target:self action:@selector(didTakePicture:)];
    fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
}

- (void)acceptOrRejectToolbar {
    fixed.width = 90;
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, reject, accept, fixed, hideFilters, nil];
    self.cameraControlsView.hidden = YES;
    self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = YES;
}

- (void)standardToolbar {
    fixed.width = 105;
    
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, takePicture, fixed, hideFilters, nil];
    self.cameraControlsView.hidden = NO;
}

- (void)setupFilters {
    int offsetX = 10;
    for (NSString *filter in self.filters ) {
        DLog(@"Setting up filter %@", filter);
        FilterButtonView *filterButton = [FilterButtonView buttonWithType:UIButtonTypeCustom];
        filterButton.frame = CGRectMake(offsetX, 5.0, 50.0, 50.0);
        filterButton.filterName = filter;
        GPUImageFilter *filterObj = (GPUImageFilter *)[self filterWithKey:filter];
        UIImage *filteredSampleImage = [filterObj imageByFilteringImage:[UIImage imageNamed:@"filters-sample.png"]];
        [filterButton setImage:filteredSampleImage forState:UIControlStateNormal];
        [filterButton addTarget:self action:@selector(didChangeFilter:) forControlEvents:UIControlEventTouchUpInside];
        filterButton.opaque = YES;
        filterButton.alpha = 1.0;
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
        filter = (GPUImageFilter *)[[GPUImageTiltShiftFilter alloc] init];
    }else if(key == @"Sepia") {
        filter = [[GPUImageSepiaFilter alloc] init];
    } else if(key == @"MissEtikateFilter") {
        filter = (GPUImageFilter *)[[GPUImageMissEtikateFilter alloc] init];
    } else if (key == @"AmatorkaFilter") {
        filter = (GPUImageFilter *)[[GPUImageAmatorkaFilter alloc] init];
    } else if (key == @"SoftElegance") {
        filter = (GPUImageFilter *)[[GPUImageSoftEleganceFilter alloc] init];
    } else if (key == @"Grayscale") {
        filter = [[GPUImageGrayscaleFilter alloc] init];
    } else if (key == @"Sketch") {
        filter = [[GPUImageSketchFilter alloc] init];
    } else if (key == @"Toon") {
        filter = (GPUImageFilter *)[[GPUImageSmoothToonFilter alloc] init];
    } else if (key == @"Erosion") {
        filter = [[GPUImageErosionFilter alloc] initWithRadius:4];
    } else if (key == @"Test") {
        filter = (GPUImageFilter *)[[GPUImageTestFilter alloc] init];
    }

    else {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }
    return filter;
}

#pragma mark LocationDelegate
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

#pragma mark MoveAndScaleDelegate
- (void)didResizeImage:(UIImage *)image {
    DLog(@"Size of image is height: %f, width: %f", image.size.height, image.size.width);
    self.imageFromLibrary = image;
    [self dismissModalViewControllerAnimated:YES];
    [self didFinishPickingFromLibrary:self];
}

- (void)didCancelResizeImage {
    [self dismissModalViewControllerAnimated:YES];
    [self setupInitialCameraState:self];
}

#pragma mark ApplicationLifecycleDelegate
- (void)applicationWillExit {
    DLog(@"TURNING OFF CAMERA");
    [self.camera stopCameraCapture];
}

- (void)applicationWillWillStart {
    DLog(@"INSIDE APPLICATION WILL START");
    self.applicationDidJustStart = YES;
    if(!self.previewImageView.image)
        [self setupInitialCameraState:self];
}

@end
