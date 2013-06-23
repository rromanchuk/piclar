//
//  CreatePhotoViewController.h
//  Piclar
//
//  Created by Ryan Romanchuk on 3/28/13.
//
//

#import "ApplicationLifecycleDelegate.h"
#import "Location.h"
#import "User+Rest.h"
#import "GPUImage.h"
#import "FacebookHelper.h"
#import "FoursquareHelper.h"
#import "Vkontakte.h"
#import "PlaceSearchViewController.h"
#import "Place+Rest.h"

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


NSString * const kOstronautFrameType1;
NSString * const kOstronautFrameType2;
NSString * const kOstronautFrameType3;
NSString * const kOstronautFrameType4;
NSString * const kOstronautFrameType5;
NSString * const kOstronautFrameType6;
NSString * const kOstronautFrameType7;
NSString * const kOstronautFrameType8;

NSString * const kOstronautFrameType9;
NSString * const kOstronautFrameType10;
NSString * const kOstronautFrameType11;
NSString * const kOstronautFrameType12;

@protocol CreateCheckinDelegate;
@interface CreatePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, LocationDelegate, ApplicationLifecycleDelegate, FacebookHelperDelegate, FoursquareHelperDelegate, VkontakteDelegate, PlaceSearchDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) Place *place;


@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *frameScrollView;
@property (weak, nonatomic) IBOutlet UIButton *fromLibraryButton;
@property (weak, nonatomic) IBOutlet UIButton *shutterButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *cameraControls;
@property (weak, nonatomic) IBOutlet UIButton *noFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *autoFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *flashOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sharePreviewImage;
@property (weak, nonatomic) IBOutlet UIButton *sharePiclarButton;
@property (weak, nonatomic) IBOutlet UIButton *shareFbButton;
@property (weak, nonatomic) IBOutlet UIButton *shareVkButton;
@property (weak, nonatomic) IBOutlet UIButton *shareCmButton;
@property (weak, nonatomic) IBOutlet UIButton *shareFsqButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIScrollView *stepScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

- (IBAction)didTapPost:(id)sender;
- (IBAction)didTapLibrary:(id)sender;
- (IBAction)didTapShutter:(id)sender;
- (IBAction)didTapCancel:(id)sender;
- (IBAction)rotateCamera:(id)sender;
- (IBAction)didTapFlash:(id)sender;
- (IBAction)didSelectFlashOn:(id)sender;
- (IBAction)didSelectFlashAuto:(id)sender;
- (IBAction)didSelectFlashOff:(id)sender;
- (IBAction)didPressFBShare:(id)sender;
- (IBAction)didPressVKShare:(id)sender;
- (IBAction)didPressFsqShare:(id)sender;
- (IBAction)didPressClassmatesShare:(id)sender;
@end

@protocol CreateCheckinDelegate <NSObject>
@required
- (void)didFinishCheckingIn;
- (void)didCanceledCheckingIn;

@end