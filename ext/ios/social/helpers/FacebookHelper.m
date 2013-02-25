//
//  FacebookHelper.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "FacebookHelper.h"
#import "RestUser.h"
#import <Accounts/Accounts.h>
@implementation FacebookHelper


+ (FacebookHelper *)shared
{
    static FacebookHelper *facebookHelper;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        facebookHelper = [[FacebookHelper alloc] init];
    });
    
    return facebookHelper;
}

- (void)syncAccount {
    
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) &&
        (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 &&
            (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
    
}
- (void)login {
    NSArray *permissions = [NSArray arrayWithObjects: @"email", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
}


- (BOOL)isAuthenticated {
    ALog(@"current state is %d", FBSession.activeSession.state);
    if (FBSession.activeSession.isOpen) {
        ALog(@"user is authenticated");
        return YES;
    }
    ALog(@"User is not authenticated");
    return NO;
}

- (BOOL)canPublishActions {
    ALog(@"Permissions granted %@", FBSession.activeSession.permissions);
    if (([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) || ![self isAuthenticated]) {
        ALog(@"cant publish actions yets");
        return NO;
    }
    
    return YES;
}

- (void)prepareForPublishing {
    ALog(@"Prepare for publishing");
    if ([self isAuthenticated]) {
        ALog(@"User authenticated, asking for publish actions");
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            NSArray *permissions = [NSArray arrayWithObjects: @"publish_actions", nil];
            [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session,
                                                                                                                                                                FBSessionState status,
                                                                                                                                                                NSError *error) {
                
                [self sessionStateChanged:session state:status error:error];
                
            }];

        }
    } else {
        [self login];
    }
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            
            ALog(@"session is open");
            if (nil == self.facebook) {
                self.facebook = [[Facebook alloc]
                                 initWithAppId:FBSession.activeSession.appID
                                 andDelegate:nil];
            }
            // Store the Facebook session information
            self.facebook.accessToken = FBSession.activeSession.accessToken;
            self.facebook.expirationDate = FBSession.activeSession.expirationDate;
            
            // Update server with new token
            if([RestUser currentUserToken]) {
                ALog("User already has token..");
                FBRequest *me = [FBRequest requestForMe];
                [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary<FBGraphUser> *my,
                                                  NSError *error) {
                    ALog(@"got data from facebook %@", my);
                    ALog(@"accessToken %@", FBSession.activeSession.accessToken);
                    [RestUser updateProviderToken:FBSession.activeSession.accessToken
                                      forProvider:@"facebook"
                                              uid:my.id
                                           onLoad:^(RestUser *restUser) {
                                               
                                           } onError:^(NSError *error) {
                                               DLog(@"error %@", error);
                                               
                                           }];
                    [self.delegate fbSessionValid];
                }];
                
            } else {
                ALog(@"No existing token, create user");
                FBRequest *me = [FBRequest requestForMe];
                [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary<FBGraphUser> *my,
                                                  NSError *error) {
                    DLog(@"got data from facebook %@", my);
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:my.id, @"user_id", session.accessToken, @"access_token", @"facebook", @"platform", [my objectForKey:@"email"], @"email", nil];
                    [RestUser create:params onLoad:^(RestUser *restUser) {
                        [self.delegate fbDidLogin:restUser];
                        
                    } onError:^(NSError *error) {
                        ALog(@"%@", error);
                        [self.delegate fbDidFailLogin:error];
                        
                    }];
                }];
            }
            
            

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
        NSError *localizedError = [NSError errorWithDomain:error.domain
                                                      code:error.code
                                                  userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"FACEBOOK_ERROR", "Facebook auth error") forKey:NSLocalizedDescriptionKey]
                                   ];
        [self.delegate fbDidFailLogin:localizedError];
    }    
}


- (void)uploadPhotoToFacebook:(UIImage *)image withMessage:(NSString *)message {
    //[[FacebookHelper shared] login];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:UIImagePNGRepresentation(image), @"picture", nil];
    if (message)
        [params setObject:message forKey:@"message"];
    
    [self.facebook requestWithGraphPath:@"me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
}

#pragma mark - FBRequestDelegate
-(void)request:(FBRequest *)request didLoad:(id)result {
    ALog(@"Request didLoad: %@ ", [request url ]);
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    if ([result isKindOfClass:[NSDictionary class]]){
        
    }
    if ([result isKindOfClass:[NSData class]]) {
    }
    ALog(@"request returns %@",result);
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    ALog("Facebook error %@", error); 
}

@end
