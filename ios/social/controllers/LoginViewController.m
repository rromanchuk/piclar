

#import "LoginViewController.h"
#import "UIImage+Resize.h"
#import "RestUser.h"
#import "BaseNavigationViewController.h"
#import "User+Rest.h"
#import "Flurry.h"
#import "UserRequestEmailViewController.h"
#import "Utils.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "InviteViewController.h"
#import "WaitForApproveViewController.h"
#import "FeedIndexViewController.h"
#import "UAPush.h"

@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize vkLoginButton = _vkLoginButton;
@synthesize authenticationPlatform;
@synthesize managedObjectContext;
@synthesize currentUser; 


#define LOGIN_STATUS_ACTIVE 1
#define LOGIN_STATUS_NEED_EMAIL 2
#define LOGIN_STATUS_NEED_INVITE 10
#define LOGIN_STATUS_WAIT_FOR_APPROVE 11

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])) {
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
    }
    
    return self;
    
}

#pragma mark - ViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateNormal];
    [self.vkLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_VK", @"Login with vk button") forState:UIControlStateHighlighted];
    [self.fbLoginButton setTitle:NSLocalizedString(@"LOGIN_WITH_FB", nil) forState:UIControlStateNormal];
    self.orLabel.text = NSLocalizedString(@"OR", "vk or fb label");

    
    NSArray *texts = [NSArray arrayWithObjects:NSLocalizedString(@"PROMO_TEXT_1", @"text 1"),
                    NSLocalizedString(@"PROMO_TEXT_2", @"text 2"),
                    NSLocalizedString(@"PROMO_TEXT_3", @"text 3"), nil];
    
    NSArray *images = [NSArray arrayWithObjects:[UIImage imageNamed:@"promo1.png"], [UIImage imageNamed:@"promo2.png"], [UIImage imageNamed:@"promo3.png"],  nil];

    int idx = 0;
    CGSize size = self.scrollView.frame.size;
    
    for (NSString * text_item in texts) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[images objectAtIndex:idx]];
        int start = ((size.width / 2) - (imageView.frame.size.width / 2));
        int offset = (start + (size.width - start)) * idx;
        [imageView setFrame:CGRectMake(start + offset, 0, imageView.frame.size.width, imageView.frame.size.height)];
        
        CGRect rect = CGRectMake(idx * size.width , imageView.frame.size.height + 5, size.width, 50);
        UILabel *label = [[UILabel alloc] initWithFrame: rect];
        label.text = text_item;
        label.textAlignment = UITextAlignmentCenter;
        label.numberOfLines = 4;
        label.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
        label.textColor = [UIColor lightGrayColor];
        [label sizeToFit];
        idx++;
        [self.scrollView addSubview:label];
        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * [texts count], self.scrollView.frame.size.height)];
    self.scrollView.delegate = self;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForUserStatusUpdate) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}



- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.currentUser) {
        DLog(@"User object already setup, go to correct screen");
        [self processUserRegistartionStatus:self.currentUser];
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
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckinsIndex"]) {
        
        UINavigationController *nc = [segue destinationViewController];
        [Flurry logAllPageViews:nc];
        FeedIndexViewController *vc = (FeedIndexViewController *) nc.topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    } else if ([[segue identifier] isEqualToString:@"RequestEmail"]) {
        UINavigationController *nc = [segue destinationViewController];
        [Flurry logAllPageViews:nc];
        UserRequestEmailViewController *vc = (UserRequestEmailViewController *)  nc.topViewController;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"InviteModal"]) {
        UINavigationController *nc = [segue destinationViewController];
        [Flurry logAllPageViews:nc];
        InviteViewController *vc = (InviteViewController *) nc.topViewController;
        vc.delegate = self;
        vc.currentUser = self.currentUser;
        vc.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"waitForApprove"]) {
        UINavigationController *nc = [segue destinationViewController];
        [Flurry logAllPageViews:nc];
        WaitForApproveViewController *vc = (WaitForApproveViewController *) nc.topViewController;
        vc.delegate = self;
        vc.currentUser = self.currentUser;
        //vc.managedObjectContext = self.managedObjectContext;
    }    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }

    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

- (IBAction)pageChanged:(id)sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    self.pageControlUsed = YES;
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
    if ([Utils NSStringIsValidEmail:_vkontakte.email]) {
        [params setValue:_vkontakte.email forKey:@"email"];
    }
    
    [RestUser create:params
              onLoad:^(RestUser *user) {
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
                  [self processUserRegistartionStatus:self.currentUser];
                  
              }
            onError:^(NSString *error) {
                [RestUser deleteCurrentUser];
                [SVProgressHUD showErrorWithStatus:error];
            }];
}

- (void)processUserRegistartionStatus:(User*)user {
    if (!user) {
        return;
    }
    int status = user.registrationStatus.intValue;
    DLog(@"process registration status: %d", status);
    
    if (status == LOGIN_STATUS_ACTIVE) {
        [self didLogIn];
    } else if(status == LOGIN_STATUS_NEED_EMAIL) {
        [self needsEmailAddresss];
    } else if(status == LOGIN_STATUS_NEED_INVITE) {
        [self needInivitation];
    } else if(status == LOGIN_STATUS_WAIT_FOR_APPROVE) {
        [self needApprove];
    }
    
}

- (void)needsEmailAddresss {
    DLog(@"Missing email address...");
    [Flurry logEvent:@"REGISTRATION_USER_WITHOUT_EMAIL"];
    [self performSegueWithIdentifier:@"RequestEmail" sender:self];
}

- (void)needInivitation {
    DLog(@"Need invitation code or first checkin");
    [Flurry logEvent:@"REGISTRATION_USER_NEED_INVITE"];
    [self performSegueWithIdentifier:@"InviteModal" sender:self];
}

- (void)needApprove {
    DLog(@"Need approve of checkin to go to feed");
    [Flurry logEvent:@"REGISTRATION_USER_NEED_APPROVE"];
    [self performSegueWithIdentifier:@"waitForApprove" sender:self];
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
                                         NSString *alias = [NSString stringWithFormat:@"%@", self.currentUser.externalId];
                                         [[UAPush shared] setAlias:alias];
                                         [[UAPush shared] updateRegistration];
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

#pragma mark - LogoutDelegate delegate methods
- (void) didLogout
{
    
    [RestUser deleteCurrentUser];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) resetCoreData];
    self.currentUser = nil;
    [_vkontakte logout];
    [[UAPush shared] setPushEnabled:NO];
    [[UAPush shared] updateRegistration];
    
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

    } onError:^(NSString *error) {
        DLog(@"Problem updating the user %@", error);
    }];
    
}

#pragma mark InvitationDelegate
- (void)didEnterValidInvitationCode{

}

@end
