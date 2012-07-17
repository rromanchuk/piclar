#import <QuartzCore/QuartzCore.h>

@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    CIContext *context; 
    NSMutableArray *filters; 
    CIImage *beginImage; 
    UIScrollView *filtersScrollView; 
    UIView *selectedFilterView; 
    UIImage *finalImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;

- (IBAction)takePicter:(id)sender;

@end
