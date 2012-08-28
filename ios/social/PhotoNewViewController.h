#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "Location.h"
#import "MoveAndScalePhotoViewController.h"

@protocol CreateCheckinDelegate;
@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationDelegate, MoveAndScaleDelegate> {
    BOOL imageIsFromLibrary;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) UIImage *imageFromLibrary;
@property (strong, nonatomic) UIImage *croppedImageFromCamera;


@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageSelectorScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet NSArray *filters;
@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *selectedFilter;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *croppedFilter;
@property (strong, nonatomic) IBOutlet NSString *selectedFilterName;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;


- (IBAction)takePicture:(id)sender;
- (IBAction)pictureFromLibrary:(id)sender;
- (void)didResizeImage:(UIImage *)image;

@end


@protocol CreateCheckinDelegate <NSObject>
@required
- (void)didFinishCheckingIn;

@end