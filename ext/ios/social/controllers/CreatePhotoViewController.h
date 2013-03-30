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

@protocol CreateCheckinDelegate;
@interface CreatePhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationDelegate, ApplicationLifecycleDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;

@property (weak, nonatomic) id <CreateCheckinDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
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


- (IBAction)didTapLibrary:(id)sender;
- (IBAction)didTapShutter:(id)sender;
- (IBAction)didTapCancel:(id)sender;
- (IBAction)rotateCamera:(id)sender;
- (IBAction)didTapFlash:(id)sender;
- (IBAction)didSelectFlashOn:(id)sender;
- (IBAction)didSelectFlashAuto:(id)sender;
- (IBAction)didSelectFlashOff:(id)sender;
@end
