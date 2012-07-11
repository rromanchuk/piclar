

#import "LoginViewController.h"
#import "UIImage+Resize.h"
#import "User.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginLabel = _loginLabel;
@synthesize signUpButton = _signUpButton;
@synthesize emailLoginButton = _emailLoginButton;
@synthesize vkLoginButton = _vkLoginButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginLabel.text = NSLocalizedString(@"LOGIN", @"Login label");
    [self.signUpButton setTitle:NSLocalizedString(@"REGISTER", @"Signup/register button")forState:UIControlStateNormal];
    
    
    _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogoutNotification:) 
                                                 name:@"DidLogoutNotification"
                                               object:nil];
    NSLog(@"inside loginview");
}

- (void)didLoginWithVk {
    NSLog(@"Authenticated with vk, now authenticate with backend");
    [SVProgressHUD show];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_vkontakte.userId, @"user_id", _vkontakte.accessToken, @"access_token", nil];
        [User create:params 
              onLoad:^(User *user) {
                  [SVProgressHUD dismiss];
                  [User setCurrentUser:user];
                  [self didLogIn];
              }
            onError:^(NSString *error) {
                [User deleteCurrentUser];
                [SVProgressHUD showErrorWithStatus:error duration:1.0];
            }];
}

- (void)didLogIn {
    NSLog(@"Everything good to go...");
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([_vkontakte isAuthorized]) {
        NSLog(@"IS VK AUTHORIZED");
        if([User currentUser]) {
            NSLog(@"User Object setup");
            [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
        } else {
            NSLog(@"User Object setup");
            [self didLoginWithVk];
        }
    }
}

- (void)viewDidUnload
{
    [self setLoginLabel:nil];
    [self setSignUpButton:nil];
    [self setEmailLoginButton:nil];
    [self setVkLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)vkLoginPressed:(id)sender {
    if (![_vkontakte isAuthorized]) 
    {
        [_vkontakte authenticate];
    }
    else
    {
        [_vkontakte logout];
    }
}


- (IBAction)loginWithEmail:(id)sender {
    NSLog(@"login with email");
    //[self performSegueWithIdentifier:@"EmailLogin" sender:self];
}


#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self dismissModalViewControllerAnimated:YES];
    [_vkontakte getUserInfo];
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    NSLog(@"USER DID LOGOUT");
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"DidLogoutNotification" 
     object:self];

}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    NSLog(@"GOT USER INFO FROM VK: %@", info);
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    NSLog(@"%@", responce);
}


- (void) didLogoutNotification:(NSNotification *) notification
{
    NSLog(@"IN NOTOFICATION");
    if ([[notification name] isEqualToString:@"DidLogoutNotification"]) {
        NSLog (@"Successfully received the test notification!");
        [self dismissModalViewControllerAnimated:YES];
    }
    
}



@end
