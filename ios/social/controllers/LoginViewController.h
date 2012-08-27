#import "Vkontakte.h"
#import "BaseViewController.h"
#import "User.h"
@interface LoginViewController : BaseViewController <VkontakteDelegate> {
    Vkontakte *_vkontakte;
}


@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;
@property (weak, nonatomic) NSString *authenticationPlatform;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;

- (IBAction)vkLoginPressed:(id)sender;
- (void)didLoginWithVk;
- (void)didLogIn;

@end

