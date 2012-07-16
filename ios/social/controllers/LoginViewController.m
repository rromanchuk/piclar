

#import "LoginViewController.h"
#import "UIImage+Resize.h"
#import "User.h"
#import "RegistrationViewController.h"
#import "BaseNavigationViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginLabel = _loginLabel;
@synthesize signUpButton = _signUpButton;
@synthesize emailLoginButton = _emailLoginButton;
@synthesize vkLoginButton = _vkLoginButton;
@synthesize authenticationPlatform;

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpObservers];
    self.loginLabel.text = NSLocalizedString(@"LOGIN", @"Login label");
    [self.signUpButton setTitle:NSLocalizedString(@"REGISTER", @"Signup/register button")forState:UIControlStateNormal];    
    NSLog(@"inside loginview");
}

- (void)didLoginWithVk {
    NSLog(@"Authenticated with vk, now authenticate with backend");
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
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
    NSLog(@"CURRENT USER IS: %@", [User currentUser]);
    if([User currentUser]) {
        NSLog(@"User object already setup, go to index");
        [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
    } else if ([_vkontakte isAuthorized]) {
        NSLog(@"VK AUTHORIZED, CREATE USER OBJECT");
        [self didLoginWithVk];
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
    self.authenticationPlatform = @"vkontakte";
    if (![_vkontakte isAuthorized]) 
    {
        [_vkontakte authenticate];
    }
    else
    {
        [_vkontakte logout];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SignupButtonClick"])
    {
        self.authenticationPlatform = @"email";
        BaseNavigationViewController *vc = [segue destinationViewController];
        RegistrationViewController *registrationController = (RegistrationViewController *) vc.topViewController;
        registrationController.isLogin = NO;
        vc.wantsBackButtonToDismissModal = YES;
        vc.notificationOnDismiss = @"DidLogoutNotification";
    } else if ([[segue identifier] isEqualToString:@"LoginButtonClick"]) {
        self.authenticationPlatform = @"email";
        BaseNavigationViewController *vc = [segue destinationViewController];
        RegistrationViewController *registrationController = (RegistrationViewController *) vc.topViewController;
        registrationController.isLogin = YES;
        vc.wantsBackButtonToDismissModal = YES;
        vc.notificationOnDismiss = @"DidLogoutNotification";
        NSLog(@"SETTING DELEGATE ON %@", registrationController);
    }
}


#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [_vkontakte logout];
    [User deleteCurrentUser];
    TFLog(@"VK LOGIN FAILED WITH: %@", error); 
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"VK_LOGIN_ERROR", @"Error when trying to authenticate vk") duration:2.0];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [User deleteCurrentUser];
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
    [self dismissModalViewControllerAnimated:YES];
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
    if ([[notification name] isEqualToString:@"DidLogoutNotification"]) {
        [User deleteCurrentUser];
        if (self.authenticationPlatform == @"vkontakte") {
            [_vkontakte logout];
        } else if(self.authenticationPlatform == @"email") {
            [self dismissModalViewControllerAnimated:YES];
        } else if([_vkontakte isAuthorized]){
            [_vkontakte logout];
        }
    }
    
}

- (void)didLoginNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"DidLoginNotification"]) {
        [self dismissModalViewControllerAnimated:NO];
        [self didLogIn];
    }
}

- (void)setUpObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogoutNotification:) 
                                                 name:@"DidLogoutNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoginNotification:) 
                                                 name:@"DidLoginNotification"
                                               object:nil];
}



@end
