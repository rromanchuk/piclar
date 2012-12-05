#import "Vkontakte.h"
#import "BaseViewController.h"
#import "User.h"
#import "UserRequestEmailViewController.h"
#import "InviteViewController.h"
#import "Logout.h"
#import "FacebookHelper.h"

@interface LoginViewController : BaseViewController <VkontakteDelegate, RequestEmailDelegate, InvitationDelegate, LogoutDelegate, FacebookHelperDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) NSString *authenticationPlatform;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *myNavigationItem;

@property BOOL pageControlUsed;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;

- (IBAction)vkLoginPressed:(id)sender;
- (IBAction)fbLoginPressed:(id)sender;
- (IBAction)pageChanged:(id)sender;
- (void)didLoginWithVk;
- (void)didLogIn;
- (void)needsEmailAddresss;
- (void)didLogout;
@end

