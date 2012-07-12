
#import "RegistrationViewController.h"
#import "User.h"
@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize registrationLabel;
@synthesize loginButton;
@synthesize isLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL", @"Placeholder for login");
    self.passwordTextField.placeholder = NSLocalizedString(@"PASSWORD", @"Placeholder for login");
    self.registrationLabel.text = NSLocalizedString(@"REGISTER", @"Registration text");
    
    [self.emailTextField becomeFirstResponder];
	// Do any additional setup after loading the view.
    
    if (self.isLogin) {
        [self.loginButton addTarget:self action:@selector(didLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginButton setTitle:NSLocalizedString(@"LOGIN", @"Login button text") forState:UIControlStateNormal];
    } else {
        [self.loginButton addTarget:self action:@selector(didRegister:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginButton setTitle:NSLocalizedString(@"REGISTER", @"Register button text") forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setRegistrationLabel:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
         
- (IBAction)didLogin:(id)sender {
    NSLog(@"IS SIGNING UP");
    [User loginUserWithEmail:self.emailTextField.text 
                    password:self.passwordTextField.text
                      onLoad:^(User *user) {
                          [SVProgressHUD dismiss];
                          [User setCurrentUser:user];
                          [[NSNotificationCenter defaultCenter] 
                           postNotificationName:@"DidLoginNotification" 
                           object:self];
                      }onError:^(NSString *error) {
                          [User deleteCurrentUser];
                          [SVProgressHUD showErrorWithStatus:error duration:1.0];
                      }];
}

- (IBAction)didRegister:(id)sender {
    [SVProgressHUD show];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text, @"email", self.passwordTextField.text, @"password", @"Ryan", @"firstname", @"Romanchuk", @"lastname", nil];
    [User create:params 
          onLoad:^(User *user) {
              [SVProgressHUD dismiss];
              [User setCurrentUser:user];
              [[NSNotificationCenter defaultCenter] 
               postNotificationName:@"DidLoginNotification" 
               object:self];
          }
         onError:^(NSString *error) {
             [User deleteCurrentUser];
             [SVProgressHUD showErrorWithStatus:error duration:1.0];
         }];

}

@end
