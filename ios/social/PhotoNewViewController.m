

#import "PhotoNewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extensions.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceSearchViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "FilterButtonView.h"
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
    self.filters = [NSArray arrayWithObjects:@"TiltShift", @"Sepia", nil];
    [self setupFilters];
    self.camera = [[GPUImageStillCamera alloc] init];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    self.selectedFilter = [[GPUImageSepiaFilter alloc] init];
    [self.selectedFilter prepareForImageCapture];
    [self.camera addTarget:self.selectedFilter];
    [self.selectedFilter addTarget:self.gpuImageView];
    
        
    [self.camera startCameraCapture];
    [self standardToolbar];
    
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
    [self setLibraryButton:nil];
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
        vc.filteredImage = self.filteredImage;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



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
    //[self applyFilter:@"TiltShift"];
    [self.selectedImageView setImage:self.filteredImage];
}

- (IBAction)didCancelOrRejectPicture:(id)sender {
    [self.camera startCameraCapture];
    [self.gpuImageView setHidden:NO];
    [self.selectedImageView setHidden:YES];
    [self standardToolbar];
    //[self applyFilter:@"TiltShift"];
    [self.selectedImageView setImage:self.filteredImage];
}


//- (void)applyFilter:(NSString *)filterName {
//    self.selectedFilter = [self.filters objectForKey:filterName];
//    NSLog(@"FILTERS ARE: %@ FILTER IS: %@", self.filters, self.selectedFilter);
//    self.filteredImage = [self.selectedFilter imageByFilteringImage:self.selectedImage];
//    self.selectedImageView.image = self.filteredImage;
//}

- (IBAction)didChangeFilter:(id)sender {
    NSString *filterName = ((FilterButtonView *)sender).filterName;
    if(self.selectedImage) {
        //[self applyFilter:filterName];
    }
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
        offsetX += 10 + filterButton.frame.size.width;
    }
    [self.filterScrollView setContentSize:CGSizeMake(offsetX, self.filterScrollView.frame.size.height)];
}

- (GPUImageFilter *)filterWithKey:(NSString *)key {
    GPUImageFilter *filter;
//    if (
//    switch(key) {
//        case @"TiltShift":
//            filter = [[GPUImageTiltShiftFilter alloc] init];
//            break;
//        case @"Sepia"
//            filter = [[GPUImageSepiaFilter alloc] init];
//            break;
//        default:
//            filter = [[GPUImageTiltShiftFilter alloc] init];
//            break;
//    }
    return filter;
}
@end
