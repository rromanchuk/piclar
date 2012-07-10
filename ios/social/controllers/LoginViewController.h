#import "Vkontakte.h"

@interface LoginViewController : UIViewController <VkontakteDelegate> {
    Vkontakte *_vkontakte;
    
    IBOutlet UIImageView *_userImage;
    IBOutlet UILabel *_userName;
    IBOutlet UILabel *_userSurName;
    IBOutlet UILabel *_userBDate;
    IBOutlet UILabel *_userGender;
    IBOutlet UILabel *_userEmail;
    IBOutlet UIButton *_vkLoginButton;
}

- (IBAction)vkLoginPressed:(id)sender;
- (void)refreshButtonState;
- (void)hideControls:(BOOL)hide;
- (void)didLoginWithVk;
@end

