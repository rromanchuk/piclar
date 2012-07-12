
@interface RegistrationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *registrationLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property BOOL isLogin; 

- (IBAction)didLogin:(id)sender; 
- (IBAction)didRegister:(id)sender;

@end


