

#import "LoginViewController.h"
#import "Gradients.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    _vkontakte = [Vkontakte sharedInstance];
    _vkontakte.delegate = self;
    NSLog(@"inside loginview");
}

- (void)refreshButtonState
{
    if (![_vkontakte isAuthorized]) 
    {
        [_vkLoginButton setTitle:@"Login" 
                 forState:UIControlStateNormal];
        [self hideControls:YES];
    } 
    else 
    {
        [_vkLoginButton setTitle:@"Logout" 
                 forState:UIControlStateNormal];
        [self hideControls:NO];
        [_vkontakte getUserInfo];
    }
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
    [self refreshButtonState];
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
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    NSLog(@"%@", responce);
}



@end
