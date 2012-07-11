#import "Vkontakte.h"

@interface LoginViewController : UIViewController <VkontakteDelegate> {
    Vkontakte *_vkontakte;
}

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *emailLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;


- (IBAction)vkLoginPressed:(id)sender;
- (IBAction)loginWithEmail:(id)sender;
- (IBAction)fuckYou:(id)sender;

- (void)didLoginWithVk;

@end

