#import "Vkontakte.h"
#import "BaseViewController.h"
@interface LoginViewController : BaseViewController <VkontakteDelegate> {
    Vkontakte *_vkontakte;
}

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *emailLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *vkLoginButton;


- (IBAction)vkLoginPressed:(id)sender;
- (void)didLoginWithVk;

@end

