

#import "LoginViewController.h"
#import "UIImage+Resize.h"
#import "RestUser.h"
#import "BaseNavigationViewController.h"
#import "CheckinsIndexViewController.h"
#import "User+Rest.h"
#import "Flurry.h"
#import "UserRequestEmailViewController.h"
#import "Utils.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize vkLoginButton = _vkLoginButton;
@synthesize authenticationPlatform;
@synthesize managedObjectContext;
@synthesize currentUser; 

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
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateNormal];
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateHighlighted];
    
}

- (void)didFinishRequestingEmail:(NSString *)email {
    DLog(@"didFinishRequestingEmail with current user %@", self.currentUser);
    self.currentUser.email = email;
    [self.currentUser pushToServer:^(RestUser *restUser) {
        DLog(@"in onload pushToServer");
        [self dismissModalViewControllerAnimated:YES];
        [self didLogIn];
    } onError:^(NSString *error) {
        DLog(@"Problem updating the user %@", error);
    }];
        
}

- (void)didLoginWithVk {
    DLog(@"Authenticated with vk, now authenticate with backend");
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog")];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_vkontakte.userId, @"user_id", _vkontakte.accessToken, @"access_token", nil];
        [RestUser create:params 
              onLoad:^(RestUser *user) {
                  user.email = _vkontakte.email;
                  user.vkontakteToken = _vkontakte.accessToken; 
                  user.vkUserId = _vkontakte.userId;
                  user.remoteProfilePhotoUrl = _vkontakte.bigPhotoUrl;
                  [SVProgressHUD dismiss];
                  [RestUser setCurrentUser:user];
                  [self findOrCreateCurrentUserWithRestUser:[RestUser currentUser]];
                  if (self.currentUser.email.length > 0 ) {
                      [self didLogIn];
                  } else {
                      [self needsEmailAddresss];
                  }
                  
              }
            onError:^(NSString *error) {
                [RestUser deleteCurrentUser];
                [SVProgressHUD showErrorWithStatus:error duration:1.0];
            }];
}

- (void)needsEmailAddresss {
    DLog(@"Missing email address...");
    [self performSegueWithIdentifier:@"RequestEmail" sender:self];
}

- (void)didLogIn {
    DLog(@"Everything good to go...");
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.currentUser) {
        DLog(@"User object already setup, go to index");
        [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
    } else if ([_vkontakte isAuthorized]) {
        DLog(@"Vk has been authorized");
        [self didLoginWithVk];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidLogoutNotification" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidLoginNotification" object:nil];
}

- (void)viewDidUnload
{
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
   if ([[segue identifier] isEqualToString:@"CheckinsIndex"]) {
        
        UINavigationController *nc = [segue destinationViewController];
        [Flurry logAllPageViews:nc];
        CheckinsIndexViewController *vc = (CheckinsIndexViewController *) nc.topViewController; 
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
   } else if ([[segue identifier] isEqualToString:@"RequestEmail"]) {
       UserRequestEmailViewController *vc = (UserRequestEmailViewController *) segue.destinationViewController;
       vc.emailFromVk = _vkontakte.email;
       vc.delegate = self;
       
   }
}


#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [_vkontakte logout];
    [RestUser deleteCurrentUser];
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
    [RestUser deleteCurrentUser];
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
    DLog(@"USER DID LOGOUT");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    DLog(@"GOT USER INFO FROM VK: %@", info);
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
}

- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce
{
    DLog(@"%@", responce);
}


- (void) didLogoutNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"DidLogoutNotification"]) {
        [RestUser deleteCurrentUser];
        [Utils resetCoreData:self.managedObjectContext.persistentStoreCoordinator];
        self.managedObjectContext = nil;
        self.currentUser = nil;
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
        [self findOrCreateCurrentUserWithRestUser:[RestUser currentUser]];
        [self dismissModalViewControllerAnimated:NO];
        [self didLogIn];
    }
}

- (void)findOrCreateCurrentUserWithRestUser:(RestUser *)user {
    self.currentUser = [User userWithRestUser:user inManagedObjectContext:self.managedObjectContext];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
