#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CIContext *context; 
    NSMutableArray *filters; 
    CIImage *beginImage; 
    UIScrollView *filtersScrollView; 
    UIView *selectedFilterView; 
    UIImage *finalImage;
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter;
    
    BOOL fromLibrary;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)takePicture:(id)sender;

@end
