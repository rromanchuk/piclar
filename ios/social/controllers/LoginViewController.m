

#import "LoginViewController.h"
#import "UIImage+Resize.h"
#import "RestUser.h"
#import "BaseNavigationViewController.h"
#import "CheckinsIndexViewController.h"
#import "User+Rest.h"
#import "Flurry.h"
#import "UserRequestEmailViewController.h"
#import "Utils.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "InviteViewController.h"

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
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateNormal];
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateHighlighted];
    [self.fbLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_FB", nil) forState:UIControlStateNormal];
    self.orLabel.text = NSLocalizedString(@"OR", "vk or fb label");
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.currentUser) {
        DLog(@"User object already setup, go to index");
        [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
    } else if ([_vkontakte isAuthorized]) {
        DLog(@"Vk has been authorized");
        [self didLoginWithVk];
    }
    
    [Flurry logEvent:@"SCREEN_LOGIN"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setVkLoginButton:nil];
    [self setOrLabel:nil];
    [self setFbLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"InviteModal"]) {
        InviteViewController *vc = (InviteViewController *) segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
    }
    
}


- (void)didLoginWithVk {
    DLog(@"Authenticated with vk, now authenticate with backend");
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Loading dialog") maskType:SVProgressHUDMaskTypeBlack];
    [Flurry logEvent:@"REGISTRATION_VK_BUTTON_PRESSED"];
    if ([Utils NSStringIsValidEmail:_vkontakte.email]) {
        [Flurry logEvent:@"REGISTRATION_VK_EMAIL_AS_LOGIN"];
    } else {
        [Flurry logEvent:@"REGISTRATION_VK_NOEMAIL_AS_LOGIN"];
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_vkontakte.userId, @"user_id", _vkontakte.accessToken, @"access_token", @"vkontakte", @"platform", nil];
        [RestUser create:params 
              onLoad:^(RestUser *user) {
                  if ([Utils NSStringIsValidEmail:_vkontakte.email] && user.email.length == 0 ) {
                      user.email = _vkontakte.email;
                  }
                  if (user.isNewUserCreated) {
                      [Flurry logEvent:@"REGISTRATION_VK_NEW_USER_CREATED"];
                  } else {
                      [Flurry logEvent:@"REGISTRATION_VK_EXIST_USER_LOGINED"];
                  }
                  user.vkontakteToken = _vkontakte.accessToken;
                  user.vkUserId = _vkontakte.userId;
                  user.remoteProfilePhotoUrl = _vkontakte.bigPhotoUrl;
                  [SVProgressHUD dismiss];
                  [RestUser setCurrentUser:user];
                  [self findOrCreateCurrentUserWithRestUser:[RestUser currentUser]];
                  if (self.currentUser.email.length > 0 && [Utils NSStringIsValidEmail:self.currentUser.email]) {
                      [self didLogIn];
                  } else {
                      [self needsEmailAddresss];
                  }
                  
              }
            onError:^(NSString *error) {
                [RestUser deleteCurrentUser];
                [SVProgressHUD showErrorWithStatus:error];
            }];
}

- (void)needsEmailAddresss {
    DLog(@"Missing email address...");
    [Flurry logEvent:@"REGISTRATION_USER_WITHOUT_EMAIL"];
    [self performSegueWithIdentifier:@"RequestEmail" sender:self];
}

- (void)didLogIn {
    DLog(@"Everything good to go...");
    [self performSegueWithIdentifier:@"CheckinsIndex" sender:self];
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

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            
            FBRequest *me = [FBRequest requestForMe];
            [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                              NSDictionary<FBGraphUser> *my,
                                              NSError *error) {
                DLog(@"got data from facebook %@", my);
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:my.id, @"user_id", session.accessToken, @"access_token", @"facebook", @"provider", [my objectForKey:@"email"], @"email", nil];
                [RestUser create:params onLoad:^(RestUser *restUser) {
                    [RestUser setCurrentUser:restUser];
                    [self findOrCreateCurrentUserWithRestUser:[RestUser currentUser]];
                    [SVProgressHUD dismiss];

                    [self didLogIn];
                } onError:^(NSString *error) {
                    ALog(@"%@", error);
                    [SVProgressHUD showErrorWithStatus:error];
                }];
            }];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}


- (IBAction)fbLoginPressed:(id)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil)];
    [self openSession];
}

- (void)openSession {
    NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES
                              completionHandler:^(FBSession *session,
                                                  FBSessionState status,
                                                  NSError *error) {
                                  
                                  if([RestUser currentUserToken]) {
                                      [RestUser updateToken:session.accessToken
                                                     onLoad:^(RestUser *restUser) {
                                          [self.currentUser setManagedObjectWithIntermediateObject:restUser];
                                          [self.currentUser updateWithRestObject:restUser];
                                          [Flurry setUserID:[NSString stringWithFormat:@"%@", self.currentUser.externalId]];
                                          if ([self.currentUser.gender boolValue]) {
                                              [Flurry setGender:@"m"];
                                          } else {
                                              [Flurry setGender:@"f"];
                                          }
                                          
                                      } onError:^(NSString *error) {
                                          DLog(@"error %@", error);

                                      }];
                                  } else {
                                      DLog(@"no existing token");
                                      [self sessionStateChanged:session state:status error:error];
                                  }
                                  
     
                              }];

}





#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    [Flurry logEvent:@"REGISTRATION_VK_RETURN_ERROR"];
    [_vkontakte logout];
    [RestUser deleteCurrentUser];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"VK_LOGIN_ERROR", @"Error when trying to authenticate vk")];
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
    [Flurry logEvent:@"REGISTRATION_VK_SUCCESSFULL"];
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

- (void) didLogout
{
    
    [RestUser deleteCurrentUser];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) resetCoreData];
    self.currentUser = nil;
    [_vkontakte logout];
    [FBSession.activeSession closeAndClearTokenInformation];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)findOrCreateCurrentUserWithRestUser:(RestUser *)user {
    self.currentUser = [User userWithRestUser:user inManagedObjectContext:self.managedObjectContext];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}


#pragma mark RequestEmailDelegate methods
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


@end
