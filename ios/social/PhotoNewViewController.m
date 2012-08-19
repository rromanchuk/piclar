

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
@interface PhotoNewViewController ()

@end

@implementation PhotoNewViewController


@synthesize libraryButton;
@synthesize previewImageView;
@synthesize selectedImage;
@synthesize filteredImage;
@synthesize filterScrollView;
@synthesize managedObjectContext;
@synthesize toolBar;
@synthesize gpuImageView;
@synthesize filters;
@synthesize camera;
@synthesize selectedFilter;
@synthesize selectedFilterName;
@synthesize imageFromLibrary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.toolBar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
        [self.toolBar setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    }
    
    //[self.toolBar setFrame:CGRectMake(0, 50, 320, 45)];
    self.filters = [NSArray arrayWithObjects:@"TiltShift", @"Sepia", @"MissEtikateFilter", @"AmatorkaFilter", @"SoftElegance", nil];
    [self setupFilters];
    self.camera = [[GPUImageStillCamera alloc] init];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    self.selectedFilter = [[GPUImageSepiaFilter alloc] init];
    [self.selectedFilter prepareForImageCapture];
    [self.camera addTarget:self.selectedFilter];
    [self.selectedFilter addTarget:self.gpuImageView];
    
        
    [self.camera startCameraCapture];
    [self standardToolbar];
    
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
    [self setSelectedImage:nil];
    [self setFilterScrollView:nil];
    [self setGpuImageView:nil];
    [self setLibraryButton:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckinCreate"])
    {
        CheckinCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.filteredImage = self.filteredImage;
        vc.place = [Place fetchClosestPlace:[Location sharedLocation] inManagedObjectContext:self.managedObjectContext];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)pictureFromLibrary:(id)sender {
    [self.camera stopCameraCapture];
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
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.selectedFilter withCompletionHandler:^(UIImage *processedImage, NSError *error){
        //NSData *dataForPNGFile = UIImageJPEGRepresentation(processedImage, 0.8);
        float size = [Utils sizeForDevice:640.0];
        self.filteredImage = [processedImage resizedImage:CGSizeMake(size, size) interpolationQuality:kCGInterpolationHigh];

        //self.selectedImage = processedImage;
        //self.filteredImage = processedImage;
        [self.gpuImageView setHidden:YES];
        [self.previewImageView setHidden:NO];
        [self acceptOrRejectToolbar];
        [self.previewImageView setImage:self.filteredImage];
    }];
}

- (IBAction)didSelectFromLibrary:(id)sender {
    [self.gpuImageView setHidden:YES];
    [self.previewImageView setHidden:NO];
    [self applyFilter];
    [self acceptOrRejectToolbar];
}

- (IBAction)didCancelOrRejectPicture:(id)sender {
    self.imageFromLibrary = nil;
    self.filteredImage = nil;
    self.selectedImage = nil;
    self.previewImageView.image = nil;
    [self.camera startCameraCapture];
    self.gpuImageView.hidden = NO;
    self.previewImageView.hidden = YES;
    [self standardToolbar];
}


- (void)applyFilter {
    if (self.imageFromLibrary) {
        NSLog(@"Applying filter");
        self.filteredImage = [self.selectedFilter imageByFilteringImage:self.imageFromLibrary];
        self.previewImageView.image = self.filteredImage;
    }
}

- (IBAction)didChangeFilter:(id)sender {
    NSLog(@"didChangeFilter called");
    NSString *filterName = ((FilterButtonView *)sender).filterName;
    self.selectedFilter = [self filterWithKey:filterName];
    if(self.imageFromLibrary) {
        NSLog(@"Changing filter to %@ and applying", filterName);
        [self applyFilter];
    } else if (filterName != self.selectedFilterName) {
        [self.camera removeAllTargets];
        [self.selectedFilter removeAllTargets];
        [self.camera addTarget:self.selectedFilter];
        [self.selectedFilter addTarget:self.gpuImageView];
        [self.selectedFilter prepareForImageCapture];
        self.selectedFilterName = filterName;
    }
    
}

- (IBAction)didSave:(id)sender {
    [self performSegueWithIdentifier:@"CheckinCreate" sender:self];
}

- (IBAction)didHideFilters:(id)sender {

}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Coming back with image");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    float size = [Utils sizeForDevice:640.0];
    self.imageFromLibrary = [image resizedImage:CGSizeMake(size, size) interpolationQuality:kCGInterpolationHigh];
    self.previewImageView.image = [self.imageFromLibrary copy];
    // UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    
    [self didSelectFromLibrary:self];
}

- (void)acceptOrRejectToolbar {
    UIImage *fromLibaryPhoto = [UIImage imageNamed:@"library.png"];
    UIImage *acceptPhoto = [UIImage imageNamed:@"photo-accept.png"];
    UIImage *rejectPhoto = [UIImage imageNamed:@"photo-reject.png"];
    UIImage *dismissPhoto = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *fromLibrary = [UIBarButtonItem barItemWithImage:fromLibaryPhoto target:self action:@selector(pictureFromLibrary:)];
    UIBarButtonItem *accept = [UIBarButtonItem barItemWithImage:acceptPhoto target:self action:@selector(didSave:)];
    UIBarButtonItem *reject = [UIBarButtonItem barItemWithImage:rejectPhoto target:self action:@selector(didCancelOrRejectPicture:)];
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
    if (key == @"TiltShift") {
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
    NSLog(@"PlaceSearch#didGetLocation with accuracy %f", [Location sharedLocation].locationManager.location.horizontalAccuracy);
    
    // If our accuracy is poor, keep trying to improve
#warning Sometimes accuracy wont ever get better and this causes a constant updating which is not energy effiecient, we should give up after x tries
    if ([Location sharedLocation].locationManager.location.horizontalAccuracy > 100.0) {
        [[Location sharedLocation] update];
    }
}

#warning handle this case better
- (void)failedToGetLocation:(NSError *)error
{
    NSLog(@"PlaceSearch#failedToGetLocation: %@", error);
    //lets try again
    [[Location sharedLocation] update];
}


@end
