

#import "PhotoNewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaceSearchViewController.h"
#import "FilterButtonView.h"
#import "CheckinCreateViewController.h"

// CoreData
#import "Place+Rest.h"
#import "UserSettings.h"
#import "UIImage+Resize.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ThreadedUpdates.h"

// Filters
#import "ImageFilterMercury.h"
#import "ImageFilterSaturn.h"
#import "ImageFilterJupiter.h"
#import "ImageFilterVenus.h"
#import "ImageFilterNeptune.h"
#import "ImageFilterPluto.h"
#import "ImageFilterMars.h"
#import "ImageFilterUranus.h"
#import "ImageFilterTriton.h"
#import "ImageFilterPhobos.h"
#import "ImageFilterPandora.h"

// Categories
#import "NSData+Exif.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "UIImage+Extensions.h"
#import "UIBarButtonItem+Borderless.h"

// frameworks
#import <MediaPlayer/MediaPlayer.h>

NSString * const kOstronautFilterTypeNormal = @"Normal";
NSString * const kOstronautFilterTypeTiltShift = @"TiltShift";
NSString * const kOstronautFilterTypeSepia = @"Sepia";

NSString * const kOstronautFilterTypeJupiter = @"Jupiter";
NSString * const kOstronautFilterTypeSaturn = @"Saturn";
NSString * const kOstronautFilterTypeMercury = @"Mercury";
NSString * const kOstronautFilterTypeVenus = @"Venus";
NSString * const kOstronautFilterTypeNeptune = @"Neptune";
NSString * const kOstronautFilterTypePluto = @"Pluto";
NSString * const kOstronautFilterTypeMars = @"Mars";
NSString * const kOstronautFilterTypeUranus = @"Uranus";
NSString * const kOstronautFilterTypePhobos = @"Phobos";
NSString * const kOstronautFilterTypeTriton = @"Triton";
NSString * const kOstronautFilterTypePandora = @"Pandora";

NSString * const kOstronautFilterTypeAquarius = @"Aquarius";
NSString * const kOstronautFilterTypeEris = @"Eris";

NSString * const kOstronautFilterTypeFrameTest1 = @"Frame1";
NSString * const kOstronautFilterTypeFrameTest2 = @"Frame2";
NSString * const kOstronautFilterTypeFrameTest3 = @"Frame3";
NSString * const kOstronautFilterTypeFrameTest4 = @"Frame4";
NSString * const kOstronautFilterTypeFrameTest5 = @"Frame5";
NSString * const kOstronautFilterTypeFrameTest6 = @"Frame6";
NSString * const kOstronautFilterTypeFrameTest7 = @"Frame7";
NSString * const kOstronautFilterTypeFrameTest8 = @"Frame8";



NSString * const kOstronautFrameType1 = @"frame-01.png";
NSString * const kOstronautFrameType2 = @"frame-02.png";
NSString * const kOstronautFrameType3 = @"frame-03.png";
NSString * const kOstronautFrameType4 = @"frame-04.png";
NSString * const kOstronautFrameType5 = @"frame-05.png";
NSString * const kOstronautFrameType6 = @"frame-06.png";
NSString * const kOstronautFrameType7 = @"frame-07.png";
NSString * const kOstronautFrameType8 = @"frame-08.png";


@interface PhotoNewViewController () {
    NSMutableSet *sampleFilterImages;
    NSDictionary *frameToFilterMap;
}

@property BOOL applicationDidJustStart;
@property NSDictionary* exifData;

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
@synthesize croppedImageFromCamera;

@synthesize applicationDidJustStart;
@synthesize currentUser;

#pragma mark - Application lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapFocus:)];
    [self.gpuImageView addGestureRecognizer:focusTap];
    
    [Utils print_free_memory:@"initial memory"];
        
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).delegate = self;
    self.filters = [NSArray arrayWithObjects:kOstronautFilterTypeNormal,
                    kOstronautFilterTypeTiltShift,
                    kOstronautFilterTypeSepia,
                    kOstronautFilterTypeAquarius,
                    kOstronautFilterTypeEris,
//                    kOstronautFilterTypeMercury,
//                    kOstronautFilterTypeSaturn,
                    kOstronautFilterTypeJupiter,
//                    kOstronautFilterTypeVenus,
                    kOstronautFilterTypeNeptune,
//                    kOstronautFilterTypePluto,
//                    kOstronautFilterTypeMars,
                    kOstronautFilterTypeUranus,
//                    kOstronautFilterTypePhobos,
                    kOstronautFilterTypeTriton,
                    kOstronautFilterTypePandora,
                    /*
                    kOstronautFilterTypeFrameTest1,
                    kOstronautFilterTypeFrameTest2,
                    kOstronautFilterTypeFrameTest3,
                    kOstronautFilterTypeFrameTest4,
                    kOstronautFilterTypeFrameTest5,
                    kOstronautFilterTypeFrameTest6,
                    kOstronautFilterTypeFrameTest7,
                    kOstronautFilterTypeFrameTest8,
                    */
                    nil];
    frameToFilterMap = [NSDictionary dictionaryWithObjectsAndKeys:
                        kOstronautFrameType1, kOstronautFilterTypeTriton,
                        kOstronautFrameType2, kOstronautFilterTypeTiltShift,
                        kOstronautFrameType3, kOstronautFilterTypeSepia,
                        kOstronautFrameType4, kOstronautFilterTypeAquarius,
                        kOstronautFrameType5, kOstronautFilterTypeEris,
                        kOstronautFrameType6, kOstronautFilterTypeNeptune,
                        kOstronautFrameType7, kOstronautFilterTypeUranus,
                        kOstronautFrameType8, kOstronautFilterTypePandora,
                        nil];


    
    [Utils print_free_memory:@"before setting up toolbar"];
    [self setupToolbarItems];
    [self setupFilters];
    [Utils print_free_memory:@"After setting up filters"];
    [self setupInitialCameraState:self];
    [Utils print_free_memory:@"after setup filters"];
    [[Location sharedLocation] updateUntilDesiredOrTimeout:10.0];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
    [volumeView sizeToFit];
    [self.view addSubview:volumeView];
    
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(YES);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // Since location updates may be running and the user can hit the back button, we must make sure the delegate
    // does not get orphaned when CheckinCreateController gets dealloc'd
    [Location sharedLocation].delegate = self;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTakePicture:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    [Flurry logEvent:@"SCREEN_PHOTO_CREATE"];
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                  object:nil];

    [Flurry logEvent:@"SCREEN_NEW_PHOTO"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    [self setSampleTitleLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckinCreate"])
    {
        CheckinCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.filteredImage = self.previewImageView.image;
        double lat = 0.0;
        double lon = 0.0;
        BOOL hasLocation = NO;
        if (self.exifData) {
            lat = [[self.exifData valueForKey:@"lat"] doubleValue];
            lon = [[self.exifData valueForKey:@"lon"] doubleValue];
            hasLocation = YES;

        } else if ([[Location sharedLocation] isLocationValid]) {
            lat = [[Location sharedLocation].latitude doubleValue];
            lon = [[Location sharedLocation].longitude doubleValue];
            hasLocation = YES;
        } 
        if (hasLocation) {
            vc.place = [Place fetchClosestPlaceToLat:lat andLon:lon inManagedObjectContext:self.managedObjectContext];
        } else {
            vc.place = nil;
        }

        vc.delegate = self.delegate;
        vc.selectedFrame = self.selectedFrame;
        vc.selectedFilter = self.selectedFilter;
        vc.isFirstTimeOpen = YES;
        vc.currentUser = self.currentUser;
        vc.metaData = self.metaData;
        vc.exifData = self.exifData;
        [Location sharedLocation].delegate = vc;
    }
}



- (IBAction)dismissModal:(id)sender {
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [Location sharedLocation].delegate = sharedAppDelegate;
    [self.camera stopCameraCapture];
    [self.delegate didCanceledCheckingIn];

}

- (IBAction)didTakePicture:(id)sender {
    self.exifData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                  object:nil];

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
        
        
        [self.camera stopCameraCapture];
        self.camera = nil;
        
        self.croppedImageFromCamera = [processedImage resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
        self.selectedFilter = [self filterWithKey:self.selectedFilterName];
        [self applyFilter];
        [SVProgressHUD dismiss];
        [self.previewImageView setHidden:NO];
        [self.gpuImageView setHidden:YES];
        [self acceptOrRejectToolbar];
        
//        self.croppedImageFromCamera = processedImage;
//        //self.previewImageView.image = [[(GPUImageFilterGroup *)self.selectedFilter terminalFilter] imageByFilteringImage:self.croppedImageFromCamera];
//        [self.camera stopCameraCapture];
//        self.camera = nil;
        //
        
    }];
    
    [Utils print_free_memory:@"outside block"];
    [Utils print_free_memory:@"after selector"];
    [Flurry logEvent:@"LIVE_PHOTO_CAPTURE"];
}


- (IBAction)setupInitialCameraState:(id)sender {

    // Remove any previous stored images
    self.imageFromLibrary = nil;
    self.croppedImageFromCamera = nil;
    self.previewImageView.image = nil;
    
    // Display video input source
    self.gpuImageView.hidden = NO;
    self.previewImageView.hidden = YES;
    
    // Remove any frames
    self.sampleTitleLabel.hidden = YES;
    self.selectedFrame = nil;
    
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

- (UIImage *)applyFrame:(UIImage *)original {
    if (!self.selectedFrame)
        return original;
    
    UIImage *frame = [UIImage imageNamed:self.selectedFrame];
    CGSize newSize = CGSizeMake(frame.size.width, frame.size.height);
    UIGraphicsBeginImageContext( newSize );
    
    // Use existing opacity as is
    [original drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [frame drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)addTemporaryTitleText {
    if (![self filterNeedsEmededText:self.selectedFrame]) {
        self.sampleTitleLabel.hidden = YES;
        return;
    }
        
    
    //self.sampleTitleLabel.text = [NSString stringWithFormat:@"%@",  NSLocalizedString(@"SAMPLE_PHOTO_LOCATION", @"the sample title for a photo")];
    if (self.exifData) {
        self.sampleTitleLabel.text = [self.exifData valueForKey:@"cityCountryString"];
    } else {
        self.sampleTitleLabel.text = [Location sharedLocation].cityCountryString;
    }
    if ([self.selectedFrame isEqualToString:kOstronautFrameType8]) {
        [self.sampleTitleLabel setFont:[UIFont fontWithName:@"Rayna" size:21]];
        self.sampleTitleLabel.textAlignment = NSTextAlignmentLeft;
    } else if ([self.selectedFrame isEqualToString:kOstronautFrameType5]) {
        self.sampleTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.sampleTitleLabel setFont:[UIFont fontWithName:@"CourierTT" size:14]];
    } else if ([self.selectedFrame isEqualToString:kOstronautFrameType2]) {
        self.sampleTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.sampleTitleLabel setFont:[UIFont fontWithName:@"Rayna" size:18]];
    }
    
    self.sampleTitleLabel.hidden = NO;
}

- (void)setLivePreviewFrame {
    self.sampleTitleLabel.hidden = YES;
    if (!self.selectedFrame){
        self.previewImageView.hidden = YES;
        return;
    }
        
    self.previewImageView.hidden = NO;
    self.previewImageView.image = [UIImage imageNamed:self.selectedFrame];
}

- (void)applyFilter {
    if (self.imageFromLibrary) {
        //DLog(@"Applying filter to photo from library");
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.imageFromLibrary];
        self.previewImageView.image = [self applyFrame:self.previewImageView.image];
        //DLog(@"orientation: %d", self.previewImageView.image.imageOrientation);
        [Flurry logEvent:@"FILTER_CHANGED_FROM_LIBRARY_PHOTO" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedFilterName, @"filter_name", nil]];
    } else if (self.croppedImageFromCamera) {
        DLog(@"Applying filter to photo from camera");
        self.previewImageView.image = [self.selectedFilter imageByFilteringImage:self.croppedImageFromCamera];
        self.previewImageView.image = [self applyFrame:self.previewImageView.image];
        [Flurry logEvent:@"FILTER_CHANGED_FROM_CAMERA_CAPTURE" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedFilterName, @"filter_name", nil]];
    }
}

#pragma mark - User events

- (IBAction)rotateCamera:(id)sender {
    
    [self.camera rotateCamera];
    if (self.camera.inputCamera.position == AVCaptureDevicePositionFront) {
        self.flashButton.hidden = YES;
    } else if(self.camera.inputCamera.position == AVCaptureDevicePositionBack) {
        self.flashButton.hidden = NO;
    }
    
}

- (IBAction)didChangeFilter:(id)sender {
    FilterButtonView *filterView = (FilterButtonView *)sender;
    NSString *filterName = filterView.filterName;
    self.selectedFrame = [self frameWithKey:filterName];
    if (![self.selectedFilterName isEqualToString:filterName]) {
        [filterView.layer setBorderWidth:1];
        [filterView.layer setBorderColor:RGBCOLOR(212, 82, 88).CGColor];
        [filterView.label setTextColor:RGBCOLOR(212, 82, 88)];
        [self.selectedFilterButtonView.layer setBorderWidth:0];
        [self.selectedFilterButtonView.label setTextColor:[UIColor whiteColor]];
    }
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
            [self addTemporaryTitleText];
        } else {
            [self setLivePreviewFrame];
            [self addTemporaryTitleText];
            [Flurry logEvent:@"FILTERS_CHANGED_LIVE" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:filterName, @"filter_name", nil]];
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
    
    // Save filtered version is done on checkin create since we need to get location first. 
    if ([self.currentUser.settings.saveOriginal boolValue] && self.croppedImageFromCamera) {
        ALog(@"saving orginal version");
        // don't save original image from library - it already stored
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[Location sharedLocation].latitude doubleValue] longitude:[[Location sharedLocation].longitude doubleValue]];

        [self.metaData setLocation:location];
        [library writeImageToSavedPhotosAlbum:[self.croppedImageFromCamera CGImage]
                                     metadata:self.metaData
                              completionBlock:nil];
    }
    
    [self performSegueWithIdentifier:@"CheckinCreate" sender:self];
}

- (IBAction)didReject:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTakePicture:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];

    self.exifData = nil;
    [self setupInitialCameraState:self];
}

- (IBAction)didTapFocus:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateRecognized) {
        ALog(@"did try to focus");
        CGPoint location = [sender locationInView:self.gpuImageView];
        ALog(@"point is at %f,%f", location.x, location.y);

        CGSize frameSize = self.gpuImageView.frame.size;
        CGPoint pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        [self focusAtPoint:pointOfInterest];

    }
}


#pragma mark - Camera input controls
- (IBAction)didClickFlash:(id)sender {
    
    if(self.flashButton.selected) {
        self.flashButton.selected =  NO;
        self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = YES;
    } else {
        self.flashButton.selected = YES;
        self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = NO;
    }
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

- (void)focusAtPoint:(CGPoint)point

{
    
    AVCaptureDevice *device = self.camera.inputCamera;
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                
                [device setExposurePointOfInterest:point];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [device unlockForConfiguration];
            
            NSLog(@"FOCUS OK");
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
}


#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [self setupInitialCameraState:self];
    [Flurry logEvent:@"PHOTO_FROM_LIBRARY_CANCELED"];
}

- (IBAction)pictureFromLibrary:(id)sender {
    [self.camera stopCameraCapture];
    self.selectedFilter = [self filterWithKey:self.selectedFilterName];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    imagePicker.allowsEditing = YES;
    [self presentModalViewController:imagePicker animated:YES];
    [Flurry logEvent:@"PHOTO_FROM_LIBRARY_CLICKED"];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:NO];
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    // don't try to juggle around orientation, rotate from the beginning if needed
    UIImage *image = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] fixOrientation];

    image = [image croppedImage:cropRect];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
             resultBlock:^(ALAsset *asset) {
                 NSDictionary *test = [[asset defaultRepresentation] metadata];
                 ALog(@"dict from test %@", test);
                 ALog(@"gps dict %@", [test objectForKey:@"{GPS}"]);
                 NSDictionary *gps = [test objectForKey:@"{GPS}"];
                 if (gps) {
                     double lon = [((NSString *)[gps objectForKey:@"Longitude"]) doubleValue];
                     double lat = [((NSString *)[gps objectForKey:@"Latitude"]) doubleValue];
                     if ([[gps objectForKey:@"LongitudeRef"] isEqualToString:@"W"]) {
                        lon = lon * -1.0;
                     }
                     if ([[gps objectForKey:@"LatitudeRef"] isEqualToString:@"S"]) {
                        lat = lat * -1.0;
                     }
                     [[ThreadedUpdates shared] loadPlacesPassivelyWithLat:[NSNumber numberWithDouble:lat] andLon:[NSNumber numberWithDouble:lon]];
                     self.exifData = [[NSMutableDictionary alloc]
                                      initWithDictionary:@{@"lat" : [NSNumber numberWithDouble:lat], @"lon": [NSNumber numberWithDouble:lon]}
                                    ];

                     [[Location sharedLocation] getCityCountryWithLat:lat andLon:lon success:^(NSString* cityCountry){
                         [self.exifData setValue:cityCountry forKey:@"cityCountryString"];
                     }];
                 }
                 
                 
                 ALAssetRepresentation *image_representation = [asset defaultRepresentation];
                 
                 // create a buffer to hold image data
                 uint8_t *buffer = (Byte*)malloc(image_representation.size);
                 NSUInteger length = [image_representation getBytes:buffer fromOffset: 0.0  length:image_representation.size error:nil];
                 
                 if (length != 0)  {
                     
                     // buffer -> NSData object; free buffer afterwards
                     NSData *adata = [[NSData alloc] initWithBytesNoCopy:buffer length:image_representation.size freeWhenDone:YES];
                     
                     // identify image type (jpeg, png, RAW file, ...) using UTI hint
                     NSDictionary* sourceOptionsDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)[image_representation UTI] ,kCGImageSourceTypeIdentifierHint,nil];
                     
                     // create CGImageSource with NSData
                     CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef) adata,  (__bridge CFDictionaryRef) sourceOptionsDict);
                     
                     // get imagePropertiesDictionary
                     CFDictionaryRef imagePropertiesDictionary;
                     imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(sourceRef,0, NULL);
                     self.metaData = [[NSMutableDictionary alloc] initWithDictionary: (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(sourceRef,0,NULL)];

                 }
                 else {
                     NSLog(@"image_representation buffer length == 0");
                 }
             }
            failureBlock:^(NSError *error) {
                NSLog(@"couldn't get asset: %@", error);
            }
     ];
    
    
    
    
    DLog(@"Coming back with image");
    
    DLog(@"Size of image is height: %f, width: %f", image.size.height, image.size.width);
    CGSize size = image.size;
    if (size.width < 640.0 && size.height < 640.0) {
        // The image is so small it doesn't need to be resized, this isn't great because it will forcefully scaled up.
        self.imageFromLibrary = image;
        [self didFinishPickingFromLibrary:self];
    } else {
        // This image needs to be scaled and cropped into a square image
        CGFloat centerX = size.width / 2;
        CGFloat centerY = size.height / 2;
        if (size.width > size.height) {
            image = [image croppedImage:CGRectMake(centerX - size.height / 2 , 0, size.height, size.height)];
        } else {
            image = [image croppedImage:CGRectMake(0 , centerY - size.width / 2, size.width, size.width)];
        }
        self.imageFromLibrary = [image resizedImage:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationHigh];
        
        [self didFinishPickingFromLibrary:self];
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
    UIImage *closePhoto = [UIImage imageNamed:@"close.png"];
    UIImage *takePicturePhoto = [UIImage imageNamed:@"camera.png"];
    
    fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    accept = [UIBarButtonItem barItemWithImage:acceptPhoto target:self action:@selector(didSave:)];
    reject = [UIBarButtonItem barItemWithImage:rejectPhoto target:self action:@selector(didReject:)];
    close = [UIBarButtonItem barItemWithImage:closePhoto target:self action:@selector(dismissModal:)];
    takePicture = [UIBarButtonItem barItemWithImage:takePicturePhoto target:self action:@selector(didTakePicture:)];
    fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
}

- (void)acceptOrRejectToolbar {
    fixed.width = 20;
    UIBarButtonItem *fixed2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed2.width = 80;
    self.toolBar.items = [NSArray arrayWithObjects: fixed, reject, fixed2, accept, fixed, nil];
    self.cameraControlsView.hidden = YES;
    self.flashOnButton.hidden = self.autoFlashButton.hidden = self.noFlashButton.hidden = YES;
}

- (void)standardToolbar {
    fixed.width = 65;
    self.toolBar.items = [NSArray arrayWithObjects:fromLibrary, fixed, takePicture, fixed, close, nil];
    self.cameraControlsView.hidden = NO;
}

- (void)setupFilters {
    sampleFilterImages = [[NSMutableSet alloc] init];
    int offsetX = 10;
    //OstronautFilterType filterType;
    for (NSString *filter in self.filters) {
        DLog(@"Setting up filter %@", filter);
        FilterButtonView *filterButton = [FilterButtonView buttonWithType:UIButtonTypeCustom];
        filterButton.frame = CGRectMake(offsetX, 5.0, 50.0, 50.0);
        filterButton.filterName = filter;
        NSString *filename = [NSString stringWithFormat:@"%@.png", filter];
        UIImage *filteredSampleImage  = [UIImage imageNamed:filename];

//        GPUImageFilter *filterObj = (GPUImageFilter *)[self filterWithKey:filter];
//        UIImage *filteredSampleImage = [filterObj imageByFilteringImage:[UIImage imageNamed:@"filters-sample.png"]];
//
//        if ([filter isEqualToString:kOstronautFilterTypeSepia]) {
//            UIImageWriteToSavedPhotosAlbum(filteredSampleImage, self, nil, nil);
//        }
//        [sampleFilterImages addObject:filteredSampleImage];
        
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
        filterButton.label = filterNameLabel;
        [self.filterScrollView addSubview:filterNameLabel];
        offsetX += 10 + filterButton.frame.size.width;
    }

    DLog(@"number of photos is %d", [sampleFilterImages count]);
    //[self saveSampleFilters];
    //self.filterScrollView.backgroundColor = [UIColor blueColor];
    [self.filterScrollView setContentSize:CGSizeMake(offsetX, 70)];
}


- (void)saveSampleFilters
{
    if(![sampleFilterImages count]) return;
    UIImage *imageToSave = [sampleFilterImages anyObject];
    [sampleFilterImages removeObject:imageToSave];
    UIImageWriteToSavedPhotosAlbum(imageToSave, self, nil, nil);
    [self performSelector:@selector(saveSampleFilters) withObject:nil afterDelay:1.0];
}

#pragma mark - Filter selectors

- (BOOL)filterNeedsEmededText:(NSString *)frame {
    if (frame == kOstronautFrameType8 || frame == kOstronautFrameType5 || frame == kOstronautFrameType2 ) {
        return YES;
    }
    return NO;
}

- (NSString *)frameWithKey:(NSString *)key {
    return [frameToFilterMap objectForKey:key];
    /*
    NSString *frame;
    if (key == kOstronautFilterTypeFrameTest1) {
        frame = kOstronautFrameType1;
    } else if (key == kOstronautFilterTypeFrameTest2) {
        frame = kOstronautFrameType2;
    } else if (key == kOstronautFilterTypeFrameTest3) {
        frame = kOstronautFrameType3;
    } else if (key == kOstronautFilterTypeFrameTest4) {
        frame = kOstronautFrameType4;
    } else if (key == kOstronautFilterTypeFrameTest5) {
        frame = kOstronautFrameType5;
    } else if (key == kOstronautFilterTypeFrameTest6) {
       frame = kOstronautFrameType6;
    } else if (key == kOstronautFilterTypeFrameTest7) {
        frame = kOstronautFrameType7;
    }  else if (key == kOstronautFilterTypeFrameTest8) {
        frame = kOstronautFrameType8;
    }
     return frame;
     */
}

- (GPUImageFilter *)filterWithKey:(NSString *)key {
    GPUImageFilter *filter;
    if (key == kOstronautFilterTypeNormal) {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }else if (key == kOstronautFilterTypeTiltShift) {
        filter = (GPUImageFilter *)[[GPUImageTiltShiftFilter alloc] init];
    }else if(key == kOstronautFilterTypeSepia) {
        filter = [[GPUImageSepiaFilter alloc] init];
    } else if(key == kOstronautFilterTypeAquarius) {
        filter = (GPUImageFilter *)[[GPUImageMissEtikateFilter alloc] init];
    } else if (key == kOstronautFilterTypeEris) {
        filter = (GPUImageFilter *)[[GPUImageAmatorkaFilter alloc] init];
    } else if (key == kOstronautFilterTypeJupiter) {
        filter = (GPUImageFilter *)[[GPUImageSoftEleganceFilter alloc] init];
    } else if (key == kOstronautFilterTypeMercury) {
        filter = (GPUImageFilter *)[[ImageFilterMercury alloc] init];
    } else if (key == kOstronautFilterTypeSaturn) {
        filter = (GPUImageFilter *)[[ImageFilterSaturn alloc] init];
    } else if (key == kOstronautFilterTypeJupiter) {
        filter = (GPUImageFilter *)[[ImageFilterJupiter alloc] init];
    } else if (key == kOstronautFilterTypeVenus) {
        filter = (GPUImageFilter *)[[ImageFilterVenus alloc] init];
    } else if (key == kOstronautFilterTypeNeptune) {
        filter = (GPUImageFilter *)[[ImageFilterNeptune alloc] init];
    } else if (key == kOstronautFilterTypeUranus) {
        filter = (GPUImageFilter *)[[ImageFilterUranus alloc] init];
    } else if (key == kOstronautFilterTypePhobos) {
        filter = (GPUImageFilter *)[[ImageFilterPhobos alloc] init];
    } else if (key == kOstronautFilterTypeTriton) {
        filter = (GPUImageFilter *)[[ImageFilterTriton alloc] init];
    } else if (key == kOstronautFilterTypePandora) {
        filter = (GPUImageFilter *)[[ImageFilterPandora alloc] init];
    } else if (key == kOstronautFilterTypePluto) {
       filter = (GPUImageFilter *)[[ImageFilterPluto alloc] init];
    }else if (key == kOstronautFilterTypeMars) {
        filter = (GPUImageFilter *)[[ImageFilterMars alloc] init];
    }
    else {
        filter = [[GPUImageBrightnessFilter alloc] init];
    }
    return filter;
}

#pragma mark LocationDelegate
- (void)didGetBestLocationOrTimeout
{
    DLog(@"Best location found");
    [[ThreadedUpdates shared] loadPlacesPassivelyWithCurrentLocation];
//    [Flurry logEvent:@"DID_GET_DESIRED_LOCATION_ACCURACY_PHOTO_CREATE"];
}

- (void)locationStoppedUpdatingFromTimeout {
    DLog(@"");
//    [Flurry logEvent:@"FAILED_TO_GET_DESIRED_LOCATION_ACCURACY_PHOTO_CREATE"];
}

- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"PlaceSearch#failedToGetLocation: %@", error);
//    [Flurry logEvent:@"FAILED_TO_GET_ANY_LOCATION"];
}


#pragma mark ApplicationLifecycleDelegate
- (void)applicationWillExit {
    DLog(@"TURNING OFF CAMERA");
    // If the user is in UIImagePicker controller, dismiss this modal before terminating.
    // It casues problems with gpuimage reinitializing when the app resumes active.
    if ([self.modalViewController isKindOfClass:[UIImagePickerController class]]) {
        [self dismissModalViewControllerAnimated:NO];
    }
    [self.camera stopCameraCapture];
}

- (void)applicationWillWillStart {
    DLog(@"INSIDE APPLICATION WILL START");
    self.applicationDidJustStart = YES;
    if(!self.previewImageView.image)
        [self setupInitialCameraState:self];
}

@end
