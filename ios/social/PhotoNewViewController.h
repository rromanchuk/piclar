#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CIContext *context; 
    CIImage *beginImage; 
    UIView *selectedFilterView; 
    UIImage *finalImage;
   
    
    BOOL fromLibrary;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UIImage *filteredImage;

@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (strong, nonatomic) IBOutlet NSDictionary *filters;
@property (strong, nonatomic) IBOutlet GPUImageStillCamera *camera;
@property (strong, nonatomic) IBOutlet GPUImageOutput<GPUImageInput> *selectedFilter;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)takePicture:(id)sender;
- (IBAction)pictureFromLibrary:(id)sender;

@end
