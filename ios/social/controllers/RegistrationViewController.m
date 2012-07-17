
#import "RegistrationViewController.h"
#import "RestUser.h"
#import "UIBarButtonItem+Borderless.h"
#import "BaseNavigationViewController.h"

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
    NSLog(@"INSIDE VIEW DID LOAD REGISTER VIEW CONTROLLER");
    [super viewDidLoad];
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL", @"Placeholder for login");
    self.passwordTextField.placeholder = NSLocalizedString(@"PASSWORD", @"Placeholder for login");
    
    [self.emailTextField becomeFirstResponder];
	// Do any additional setup after loading the view.
    
    if (self.isLogin) {
        self.registrationLabel.text = NSLocalizedString(@"LOGIN", @"Registration text");
        [self.loginButton addTarget:self action:@selector(didLogin:) forControlEvents:UIControlEventTouchUpInside];
        [self.loginButton setTitle:NSLocalizedString(@"LOGIN", @"Login button text") forState:UIControlStateNormal];
    } else {
        self.registrationLabel.text = NSLocalizedString(@"REGISTER", @"Registration text");
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
    [RestUser loginUserWithEmail:self.emailTextField.text 
                    password:self.passwordTextField.text
                      onLoad:^(RestUser *user) {
                          [SVProgressHUD dismiss];
                          [RestUser setCurrentUser:user];
                          [[NSNotificationCenter defaultCenter] 
                           postNotificationName:@"DidLoginNotification" 
                           object:self];
                      }onError:^(NSString *error) {
                          [RestUser deleteCurrentUser];
                          [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LOGIN_ERROR", @"Problem logging user in") duration:2.0];
                      }];
}

- (IBAction)didRegister:(id)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.emailTextField.text, @"email", self.passwordTextField.text, @"password", @"Ryan", @"firstname", @"Romanchuk", @"lastname", nil];
    [RestUser create:params 
          onLoad:^(RestUser *user) {
              [SVProgressHUD dismiss];
              [RestUser setCurrentUser:user];
              [[NSNotificationCenter defaultCenter] 
               postNotificationName:@"DidLoginNotification" 
               object:self];
          }
         onError:^(NSString *error) {
             [RestUser deleteCurrentUser];
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"REGISTRATION_ERROR", @"Problem logging user in") duration:2.0];
         }];

}

@end
