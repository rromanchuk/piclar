//
//  CreatePhotoViewController.m
//  Piclar
//
//  Created by Ryan Romanchuk on 3/28/13.
//
//

#import "CreatePhotoViewController.h"
#import "FilterButtonView.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
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
#import "UIImage+Resize.h"

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>

#import "AppDelegate.h"

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



NSString * const kOstronautFrameType1 = @"frame-01";
NSString * const kOstronautFrameType2 = @"frame-02";
NSString * const kOstronautFrameType3 = @"frame-03";
NSString * const kOstronautFrameType4 = @"frame-04";
NSString * const kOstronautFrameType5 = @"frame-05";
NSString * const kOstronautFrameType6 = @"frame-06";
NSString * const kOstronautFrameType7 = @"frame-07";
NSString * const kOstronautFrameType8 = @"frame-08";
NSString * const kOstronautFrameType9 = @"frame-09";
NSString * const kOstronautFrameType10 = @"frame-10";
NSString * const kOstronautFrameType11 = @"frame-11";
NSString * const kOstronautFrameType12 = @"frame-12";

@interface CreatePhotoViewController () {
    NSInteger _currentPage;

}
@property (strong, nonatomic) NSArray *filters;
@property (strong, nonatomic) NSArray *frames;

@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *selectedFilter;
@property (strong, nonatomic) NSString *selectedFrame;

@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *croppedFilter;
@property (strong, nonatomic) NSString *selectedFilterName;
@property (strong, nonatomic) FilterButtonView *selectedFilterButtonView;

@property (strong, nonatomic) NSString *selectedFrameName;
@property (strong, nonatomic) FilterButtonView *selectedFrameButtonView;

@property (strong, nonatomic) NSMutableSet *sampleFilterImages;
@property (strong, nonatomic) NSMutableSet *sampleFrameImages;


@property (strong, nonatomic) UIImage *croppedImageFromCamera;
@property (strong, nonatomic) UIImage *imageFromLibrary;
@property (strong, nonatomic) UIImage *filteredImage;

@property (strong, nonatomic) NSMutableDictionary *metaData;

@property BOOL applicationDidJustStart;
@property BOOL cameraOn;

@property (strong, nonatomic) NSDictionary *exifData;
@end

@implementation CreatePhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.stepScrollView setContentSize:CGSizeMake(1279, self.stepScrollView.frame.size.height)];
    self.stepScrollView.delegate = self;
    _currentPage = 0;
	// Do any additional setup after loading the view.
    
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
    self.frames = @[kOstronautFrameType1, kOstronautFrameType2, kOstronautFrameType3, kOstronautFrameType4, kOstronautFrameType5, kOstronautFrameType6, kOstronautFrameType7, kOstronautFrameType8, kOstronautFrameType9, kOstronautFrameType10, kOstronautFrameType11, kOstronautFrameType12];
    [self setupFilters];
    [self setupFrames];
    self.shareFbButton.selected = [[FacebookHelper shared] canPublishActions];
    self.shareVkButton.selected = [[Vkontakte sharedInstance] isAuthorized];
    self.shareFsqButton.selected = [[FoursquareHelper shared] sessionIsValid];
    [self setupInitialCameraState:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PlaceSelect"]) {
        PlaceSearchViewController *vc = (PlaceSearchViewController *)segue.destinationViewController;
        vc.placeSearchDelegate = self;
        vc.managedObjectContext = self.managedObjectContext;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)didChangeFilter:(id)sender {
    FilterButtonView *filterView = (FilterButtonView *)sender;
    NSString *filterName = filterView.filterName;
    
    if (![self.selectedFilterName isEqualToString:filterName]) {
        [filterView.layer setBorderWidth:1];
        [filterView.layer setBorderColor:RGBCOLOR(212, 82, 88).CGColor];
        [filterView.label setTextColor:RGBCOLOR(212, 82, 88)];
        [self.selectedFilterButtonView.layer setBorderWidth:0];
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
        }
    }
}

- (IBAction)didChangeFrame:(id)sender {
    FilterButtonView *filterView = (FilterButtonView *)sender;
    NSString *filterName = filterView.filterName;
    
    if (![self.selectedFrameName isEqualToString:filterName]) {
        [filterView.layer setBorderWidth:1];
        [filterView.layer setBorderColor:RGBCOLOR(212, 82, 88).CGColor];
        [filterView.label setTextColor:RGBCOLOR(212, 82, 88)];
        [self.selectedFrameButtonView.layer setBorderWidth:0];
    }
    self.selectedFrameButtonView = filterView;
    DLog(@"didChangeFilter called with %@", filterName);
    
    if(filterName != self.selectedFrameName) {
        [self.camera removeAllTargets];
        [self.selectedFilter removeAllTargets];
        self.selectedFrameName = filterName;
        self.previewImage.image = [self applyFrame:self.filteredImage];
    }
}


- (IBAction)didTakePicture:(id)sender {
    self.exifData = nil;
    DLog(@"Did take picture");
    if (!self.cameraOn) {
        [self setupInitialCameraState:self];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"APPLYING_FILTER", @"Loading screen as we apply filter")];
    GPUImageCropFilter *cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0, 0.125, 1.0, 0.75)];
    [self.camera removeAllTargets];
    [self.camera addTarget:cropFilter];
    [cropFilter prepareForImageCapture];
    [self.camera capturePhotoAsImageProcessedUpToFilter:cropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        DLog(@"Image width: %f height: %f", processedImage.size.width, processedImage.size.height);
        
                
        self.croppedImageFromCamera = [processedImage resizedImage:CGSizeMake(640.0, 640.0) interpolationQuality:kCGInterpolationHigh];
        self.previewImage.image = self.croppedImageFromCamera;
        
        [SVProgressHUD dismiss];
        [self.previewImage setHidden:NO];
        [self.gpuImageView setHidden:YES];
        
        self.cameraOn = NO;
        [self.camera stopCameraCapture];
        [self scrollToNext];
    }];
    
   
    [Flurry logEvent:@"LIVE_PHOTO_CAPTURE"];
}


- (void)applyFilter {
    if (self.imageFromLibrary) {
        self.filteredImage = [self.selectedFilter imageByFilteringImage:self.imageFromLibrary];
        self.previewImage.image = self.filteredImage;
        DLog(@"orientation: %d", self.previewImage.image.imageOrientation);
        [Flurry logEvent:@"FILTER_CHANGED_FROM_LIBRARY_PHOTO" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedFilterName, @"filter_name", nil]];
    } else if (self.croppedImageFromCamera) {
        DLog(@"Applying filter to photo from camera");
        self.filteredImage = [self.selectedFilter imageByFilteringImage:self.croppedImageFromCamera];
        self.previewImage.image = self.filteredImage;
        [Flurry logEvent:@"FILTER_CHANGED_FROM_CAMERA_CAPTURE" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedFilterName, @"filter_name", nil]];
    }
}

- (UIImage *)applyFrame:(UIImage *)original {
        
    UIImage *frame = [UIImage imageNamed:self.selectedFrameName];
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


- (IBAction)setupInitialCameraState:(id)sender {
    
    // Remove any previous stored images
    self.imageFromLibrary = nil;
    self.croppedImageFromCamera = nil;
    self.previewImage.image = nil;
    
    // Display video input source
    self.gpuImageView.hidden = NO;
    self.previewImage.hidden = YES;
    
    // Remove any frames
    //self.sampleTitleLabel.hidden = YES;
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

    
    self.cameraOn = YES;
    [self.camera startCameraCapture];
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
    if(!self.croppedImageFromCamera && !self.imageFromLibrary)
        [self setupInitialCameraState:self];
}


- (void)viewDidUnload {
    [self setFilterScrollView:nil];
    [self setFrameScrollView:nil];
    [self setFromLibraryButton:nil];
    [self setShutterButton:nil];
    [self setCancelButton:nil];
    [self setFlashButton:nil];
    [self setCameraControls:nil];
    [self setFlashButton:nil];
    [self setGpuImageView:nil];
    [self setSharePreviewImage:nil];
    [self setSharePiclarButton:nil];
    [self setShareFbButton:nil];
    [self setShareVkButton:nil];
    [self setShareCmButton:nil];
    [self setSubmitButton:nil];
    [self setStepScrollView:nil];
    [self setPreviewImage:nil];
    [self setShareFsqButton:nil];
    [super viewDidUnload];
}

#pragma mark - setup filters
- (void)setupFrames {
    self.sampleFrameImages = [[NSMutableSet alloc] init];
    int offsetX = 10;
    //OstronautFilterType filterType;
    for (NSString *filter in self.frames) {
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
        [filterButton addTarget:self action:@selector(didChangeFrame:) forControlEvents:UIControlEventTouchUpInside];
        filterButton.opaque = YES;
        filterButton.alpha = 1.0;
        [self.frameScrollView addSubview:filterButton];
        offsetX += 10 + filterButton.frame.size.width;
    }
    
    //DLog(@"number of photos is %d", [sampleFilterImages count]);
    //[self saveSampleFilters];
    //self.filterScrollView.backgroundColor = [UIColor blueColor];
    [self.frameScrollView setContentSize:CGSizeMake(offsetX, 70)];
    
    //[self standardToolbar];

}

- (void)setupFilters {
    self.sampleFilterImages = [[NSMutableSet alloc] init];
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
        offsetX += 10 + filterButton.frame.size.width;
    }
    
    //DLog(@"number of photos is %d", [sampleFilterImages count]);
    //[self saveSampleFilters];
    //self.filterScrollView.backgroundColor = [UIColor blueColor];
    [self.filterScrollView setContentSize:CGSizeMake(offsetX, 70)];
    
    //[self standardToolbar];
}

#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    //[self setupInitialCameraState:self];
    [Flurry logEvent:@"PHOTO_FROM_LIBRARY_CANCELED"];
}

- (IBAction)didTapPost:(id)sender {
    [self createCheckin];
}

- (IBAction)didTapLibrary:(id)sender {
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
                     //[[ThreadedUpdates shared] loadPlacesPassivelyWithLat:[NSNumber numberWithDouble:lat] andLon:[NSNumber numberWithDouble:lon]];
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
        self.previewImage.image = self.imageFromLibrary;
        [self didFinishPickingFromLibrary:self];
    }
}


- (IBAction)didFinishPickingFromLibrary:(id)sender {
//    [self.selectedFilter prepareForImageCapture];
//    [self applyFilter];
    [self.gpuImageView setHidden:YES];
    [self.previewImage setHidden:NO];
    [self scrollToNext];
//    [self acceptOrRejectToolbar];
    
}

- (IBAction)didTapShutter:(id)sender {
    [self didTakePicture:self];
}

- (IBAction)didTapCancel:(id)sender {
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [Location sharedLocation].delegate = sharedAppDelegate;
    [self.camera stopCameraCapture];
    [self.delegate didCanceledCheckingIn];

}

- (IBAction)rotateCamera:(id)sender {
}


#pragma mark - Camera input controls
- (IBAction)didTapFlash:(id)sender {
    
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
    [self didTapFlash:self];
}

- (IBAction)didSelectFlashAuto:(id)sender {
    NSError *error;
    if ([self.camera.inputCamera lockForConfiguration:&error]) {
        [self.camera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
        [self.camera.inputCamera unlockForConfiguration];
    }
    [self didTapFlash:self];
    
}

- (IBAction)didSelectFlashOff:(id)sender {
    NSError *error;
    if ([self.camera.inputCamera lockForConfiguration:&error]) {
        [self.camera.inputCamera setFlashMode:AVCaptureFlashModeOff];
        [self.camera.inputCamera unlockForConfiguration];
    }
    [self didTapFlash:self];
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

#pragma mark - Filter selectors

- (BOOL)filterNeedsEmededText:(NSString *)frame {
    if (frame == kOstronautFrameType8 || frame == kOstronautFrameType5 || frame == kOstronautFrameType2 ) {
        return YES;
    }
    return NO;
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

- (void)createCheckin {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[Location sharedLocation].latitude doubleValue] longitude:[[Location sharedLocation].longitude doubleValue]];
    
    NSData *imageData = UIImageJPEGRepresentation(self.previewImage.image, 0.9);
    NSMutableData *mImageData = [imageData mutableCopy];
    
    if (!self.metaData) {
        ALog(@"no meta data, add gps");
        self.metaData = [[NSMutableDictionary alloc] init];
        [self.metaData setLocation:location];
    }
    
//    //ALog(@"metadata after is %@", self.metaData);
//    NSData *imageData;
//    if (self.processedImage) {
//        [self.metaData setImageOrientarion:self.processedImage.imageOrientation];
//        imageData = UIImageJPEGRepresentation(self.processedImage, 0.9);
//    } else {
//        [self.metaData setImageOrientarion:self.filteredImage.imageOrientation];
//        imageData = UIImageJPEGRepresentation(self.filteredImage, 0.9);
//    }
//    NSMutableData *imageDataWithExif = [imageData addExifData:self.metaData];
//    
//    NSArray  *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *imageName = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TestImage.jpg"];
//    [imageDataWithExif writeToFile:imageName atomically:YES];
//    
//    // Only save the filtered image if it is enabled by the user and they didn't select the "normal" filter
//    if (![self.selectedFilter isKindOfClass:[GPUImageBrightnessFilter class]] && [self.currentUser.settings.saveFiltered boolValue]) {
//        ALog(@"saving filtered version");
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        self.filteredImage = (self.processedImage) ? self.processedImage : self.filteredImage;
//        [library writeImageToSavedPhotosAlbum:[self.filteredImage CGImage]
//                                     metadata:self.metaData
//                              completionBlock:nil];
//    }
    
    NSMutableArray *platforms = [[NSMutableArray alloc] init];
    if (self.shareVkButton.selected)  {
        ALog(@"uploading to vk");
        [platforms addObject:@"vkontakte"];
        [Flurry logEvent:@"SHARED_ON_VKONTAKTE"];
        if (self.place) {
            [[Vkontakte sharedInstance] postImageToWall:imageData text:@"" link:[NSURL URLWithString:@"http://piclar.com"] lat:[self.place.lat stringValue] lng:[self.place.lon stringValue]];
        } else {
            [[Vkontakte sharedInstance] postImageToWall:imageData text:@""];
        }
        
    }
    
    if (self.shareFbButton.selected) {
        [platforms addObject:@"facebook"];
        [Flurry logEvent:@"SHARED_ON_FACEBOOK"];
        [[FacebookHelper shared] uploadPhotoToFacebook:self.previewImage.image withMessage:@""];
        ALog(@"uploading to facebook");
    }

    if (self.shareFsqButton.selected) {
        [platforms addObject:@"foursquare"];
    }
    
    self.submitButton.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in") maskType:SVProgressHUDMaskTypeBlack];
    [RestFeedItem createFeedItemWithPlace:nil
                                 andPhoto:mImageData
                               andComment:nil
                                andRating:nil
                         shareOnPlatforms:nil
                                   onLoad:^(RestFeedItem *restFeedItem) {
                                       [SVProgressHUD dismiss];
                                       FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                                       NSError *error;
                                       [self.managedObjectContext save:&error];
                                       AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                       [sharedAppDelegate writeToDisk];
                                       ALog(@"new feed item is %@", feedItem);
                                       
                                       [self.delegate didFinishCheckingIn];
                                   }
                                  onError:^(NSError *error) {
                                      self.submitButton.enabled = YES;
                                      [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                      DLog(@"Error creating checkin: %@", error);
                                  }];
    
}

#pragma mark - FoursquareHelperDelegate methods
- (void)fsqSessionValid:(BZFoursquare *)foursquare {
    ALog(@"Foursquare session state changed.. delegate called");
    [RestUser updateProviderToken:foursquare.accessToken forProvider:@"fsq" uid:nil onLoad:^(RestUser *restUser) {
        [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
        //self.fsqSharebutton.selected = YES;
    } onError:^(NSError *error) {
        ALog(@"unable to update vk token %@", error);
        //self.fsqSharebutton.selected = NO;
    }];
}

#pragma mark - FacebookHelperDelegate methods
- (void)fbSessionValid {
    ALog(@"Facebook session state changed.. delegate called");
    if ([[FacebookHelper shared ] canPublishActions]) {
        self.shareFbButton.selected = YES;
    } else {
        self.shareFbButton.selected = NO;
    }
    
}

- (void)fbDidFailLogin:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    self.shareFbButton.selected = NO;
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    ALog(@"vk authorization failed %@", error);
    [Flurry logError:@"VK Failure" message:@"Failure on share with vk" error:error];
    self.shareVkButton.selected = NO;
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    ALog(@"user canceled auth");
    [self dismissModalViewControllerAnimated:YES];
    self.shareVkButton.selected = NO;
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    self.shareVkButton.selected = YES;
    [RestUser updateProviderToken:vkontakte.accessToken forProvider:@"vkontakte" uid:vkontakte.userId onLoad:^(RestUser *restUser) {
        self.shareVkButton.selected = YES;
    } onError:^(NSError *error) {
        ALog(@"unable to update vk token %@", error);
        self.shareVkButton.selected = NO;
    }];
    ALog(@"vk auth success");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    DLog(@"USER DID LOGOUT");
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    DLog(@"GOT USER INFO FROM VK: %@", info);
}


- (IBAction)didPressFBShare:(id)sender {
    if (!self.shareFbButton.selected) {
        if (![[FacebookHelper shared] canPublishActions]) {
            DLog(@"Facebook session not open, opening now");
            [[FacebookHelper shared] prepareForPublishing];
        }
    }
    self.shareFbButton.selected = !self.shareFbButton.selected;
}

- (IBAction)didPressVKShare:(id)sender {
    if (!self.shareVkButton.selected) {
        if (![[Vkontakte sharedInstance] isAuthorized])
            [[Vkontakte sharedInstance] authenticate];
    }
    self.shareVkButton.selected = !self.shareVkButton.selected;
}

- (IBAction)didPressFsqShare:(id)sender {
    [[FoursquareHelper shared] authorize];
}

- (IBAction)didPressClassmatesShare:(id)sender {
}

- (void)scrollToNext {
    _currentPage++;
    float width = self.stepScrollView.frame.size.width;
    //NSLog(@"scrolling to %f page %d", width, _currentPage);
    [self.stepScrollView setContentOffset:CGPointMake(width * _currentPage, 0.0f) animated:YES];
}

#pragma mark PlaceSearchDelegate methods
- (void)didSelectNewPlace:(Place *)newPlace {
    [Flurry logEvent:@"CHECKIN_NEW_PLACE_SELECTED"];
    [Location sharedLocation].delegate = self;
    DLog(@"didSelectNewPlace");
    if (newPlace) {
        self.place = newPlace;
        //[self.selectPlaceButton setTitle:self.place.title forState:UIControlStateNormal];
        //[self applyPhotoTitle];
    }
    [self dismissModalViewControllerAnimated:YES];
}


@end
