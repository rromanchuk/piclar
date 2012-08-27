#import "Vkontakte.h"
#import "BaseViewController.h"
#import "User.h"
#import "UserRequestEmailViewController.h"

@interface LoginViewController : BaseViewController <VkontakteDelegate, RequestEmailDelegate> {
    Vkontakte *_vkontakte;
}


@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) NSString *authenticationPlatform;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;

- (IBAction)vkLoginPressed:(id)sender;
- (void)didLoginWithVk;
- (void)didLogIn;
- (void)needsEmailAddresss;
@end

