#import "BaseViewController.h"

@interface RegistrationViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *registrationLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
