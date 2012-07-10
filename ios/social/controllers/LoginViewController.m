

#import "LoginViewController.h"
#import "Gradients.h"
#import "UIImage+Resize.h"
#import "User.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    [self didLoginWithVk];
    NSLog(@"inside loginview");
}

- (void)didLoginWithVk {
    NSLog(@"Authenticated with vk, now authenticate with backend");
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_vkontakte.userId, @"user_id", _vkontakte.accessToken, @"access_token", nil];
        [User create:params 
              onLoad:^(User *user) {
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CAGradientLayer *bgLayer = [Gradients greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([_vkontakte isAuthorized]) {
        NSLog(@"IS AUTHORIZED");
        [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
    }
}

- (void)viewDidUnload
{
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



@end
