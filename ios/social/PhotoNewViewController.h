#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "Location.h"
@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationDelegate> {
    BOOL imageIsFromLibrary;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UIImage *imageFromLibrary;
@property (weak, nonatomic) IBOutlet UIImage *filteredImage;

@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageSelectorScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet NSArray *filters;
@property (strong, nonatomic) IBOutlet GPUImageStillCamera *camera;
@property (strong, nonatomic) IBOutlet GPUImageOutput<GPUImageInput> *selectedFilter;
@property (strong, nonatomic) IBOutlet NSString *selectedFilterName;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)takePicture:(id)sender;
- (IBAction)pictureFromLibrary:(id)sender;

@end
