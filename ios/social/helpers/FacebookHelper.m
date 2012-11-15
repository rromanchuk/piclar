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
            
//            FBRequest *me = [FBRequest requestForMe];
//            [me startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                              NSDictionary<FBGraphUser> *my,
//                                              NSError *error) {
//                DLog(@"got data from facebook %@", my);
//                
//                
//            }];
            
            // Update server with new token
            if([RestUser currentUserToken]) {
                [RestUser updateToken:session.accessToken
                               onLoad:^(RestUser *restUser) {
                                   
                               } onError:^(NSString *error) {
                                   DLog(@"error %@", error);
                                   
                               }];
            } else {
                DLog(@"no existing token");
                
            }
            ALog(@"session is open");
            [self.delegate facebookSessionStateDidChange:YES withSession:session];

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


+ (void)uploadPhotoToFacebook:(UIImage *)image {
    [[FacebookHelper shared] login];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:UIImagePNGRepresentation(image), @"picture", nil];
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error)
     {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          [result objectForKey:@"id"]];
         }
         ALog(@"Upload failure with %@", alertText);
         ALog(@"%@", error);
     }];
    
}



@end
