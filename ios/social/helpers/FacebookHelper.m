//
//  FacebookHelper.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "FacebookHelper.h"
#import "RestUser.h"
@implementation FacebookHelper
+ (void)openSession {
    NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES
                              completionHandler:^(FBSession *session,
                                                  FBSessionState status,
                                                  NSError *error) {
                                  
                                  if([RestUser currentUserToken]) {
                                      [RestUser updateToken:session.accessToken
                                                     onLoad:^(RestUser *restUser) {
                                                                                                                  
                                                     } onError:^(NSString *error) {
                                                         DLog(@"error %@", error);
                                                         
                                                     }];
                                  } else {
                                      DLog(@"no existing token");
                                      [FacebookHelper sessionStateChanged:session state:status error:error];
                                  }
                                  
                                  
                              }];
    
}

+ (void)sessionStateChanged:(FBSession *)session
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


@end
