#import "Vkontakte.h"

@interface LoginViewController : UIViewController <VkontakteDelegate> {
    Vkontakte *_vkontakte;
    IBOutlet UIButton *_vkLoginButton;
}

- (IBAction)vkLoginPressed:(id)sender;
- (void)didLoginWithVk;
@end

