

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

- (void)refreshButtonState
{
//    if (![_vkontakte isAuthorized]) 
//    {
//        [_vkLoginButton setTitle:@"Login" 
//                 forState:UIControlStateNormal];
//        [self hideControls:YES];
//    } 
//    else 
//    {
//        [_vkLoginButton setTitle:@"Logout" 
//                 forState:UIControlStateNormal];
//        [self hideControls:NO];
//        [_vkontakte getUserInfo];
//    }
}

- (void)hideControls:(BOOL)hide
{
    [_userImage setHidden:hide];
    [_userName setHidden:hide];
//    [_userSurName setHidden:hide];
//    [_userBDate setHidden:hide];
//    [_userGender setHidden:hide];
//    [_userEmail setHidden:hide];
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
    [self refreshButtonState];
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    NSLog(@"%@", info);
    
    NSString *photoUrl = [info objectForKey:@"photo_big"];
    NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
    _userImage.image = [UIImage imageWithData:photoData];
    
    _userName.text = [info objectForKey:@"first_name"];
//    _userSurName.text = [info objectForKey:@"last_name"];
//    _userBDate.text = [info objectForKey:@"bdate"];
//    _userGender.text = [NSString stringWithGenderId:[[info objectForKey:@"sex"] intValue]];
//    _userEmail.text = [info objectForKey:@"email"];
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    NSLog(@"%@", responce);
}



@end
