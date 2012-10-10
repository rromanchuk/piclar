#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "Location.h"
#import "MoveAndScalePhotoViewController.h"
#import "FilterButtonView.h"
#import "ApplicationLifecycleDelegate.h"
#import "User+Rest.h"

#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>


NSString * const kOstronautFilterTypeNormal;
NSString * const kOstronautFilterTypeTiltShift;
NSString * const kOstronautFilterTypeSepia;
NSString * const kOstronautFilterTypeJupiter;
NSString * const kOstronautFilterTypeSaturn;
NSString * const kOstronautFilterTypeMercury;
NSString * const kOstronautFilterTypeVenus;
NSString * const kOstronautFilterTypeNeptune;
NSString * const kOstronautFilterTypePluto;
NSString * const kOstronautFilterTypeMars;
NSString * const kOstronautFilterTypeUranus;
NSString * const kOstronautFilterTypePhobos;
NSString * const kOstronautFilterTypeTriton;
NSString * const kOstronautFilterTypePandora;

NSString * const kOstronautFilterTypeAquarius;
NSString * const kOstronautFilterTypeEris;

NSString * const kOstronautFilterTypeFrameTest1;
NSString * const kOstronautFilterTypeFrameTest2;
NSString * const kOstronautFilterTypeFrameTest3;
NSString * const kOstronautFilterTypeFrameTest4;
NSString * const kOstronautFilterTypeFrameTest5;
NSString * const kOstronautFilterTypeFrameTest6;
NSString * const kOstronautFilterTypeFrameTest7;
NSString * const kOstronautFilterTypeFrameTest8;




NSString * const kOstronautFrameType1;
NSString * const kOstronautFrameType2;
NSString * const kOstronautFrameType3;
NSString * const kOstronautFrameType4;
NSString * const kOstronautFrameType5;
NSString * const kOstronautFrameType6;
NSString * const kOstronautFrameType7;
NSString * const kOstronautFrameType8;

@protocol CreateCheckinDelegate;
@interface PhotoNewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationDelegate, MoveAndScaleDelegate, ApplicationLifecycleDelegate> {
    BOOL imageIsFromLibrary;
    UIBarButtonItem *fromLibrary;
    UIBarButtonItem *accept;
    UIBarButtonItem *reject;
    UIBarButtonItem *showFilters;
    UIBarButtonItem *hideFilters;
    UIBarButtonItem *fixed;
    UIBarButtonItem *takePicture;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *libraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UILabel *sampleTitleLabel;


@property (weak, nonatomic) IBOutlet UIView *cameraControlsView;
@property (weak, nonatomic) IBOutlet UIButton *noFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *autoFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;

@property (strong, nonatomic) UIImage *croppedImageFromCamera;
@property (strong, nonatomic) UIImage *imageFromLibrary;


@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIScrollView *imageSelectorScrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;

@property (weak, nonatomic) NSArray *filters;

@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *selectedFilter;
@property (strong, nonatomic) NSString *selectedFrame;

@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *croppedFilter;
@property (strong, nonatomic) IBOutlet NSString *selectedFilterName;
@property (strong, nonatomic) FilterButtonView *selectedFilterButtonView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;

@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;


- (IBAction)takePicture:(id)sender;
- (IBAction)rotateCamera:(id)sender;
- (IBAction)didSelectFlashOn:(id)sender;
- (IBAction)didSelectFlashAuto:(id)sender;
- (IBAction)didSelectFlashOff:(id)sender;
- (IBAction)pictureFromLibrary:(id)sender;
- (void)didResizeImage:(UIImage *)image;
- (void)applicationWillExit;
@end



@protocol CreateCheckinDelegate <NSObject>
@required
- (void)didFinishCheckingIn;
- (void)didCanceledCheckingIn;

@end