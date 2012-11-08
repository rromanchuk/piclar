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
    NSArray *permissions = [NSArray arrayWithObjects:@"email", @"publish_actions", nil];
    [FBSession openActiveSessionWithPermissions:permissions allowLoginUI:YES
                              completionHandler:^(FBSession *session,
                                                  FBSessionState status,
                                                  NSError *error) {
                                  
                                  [FacebookHelper sessionStateChanged:session state:status error:error];
                                  
                              }];
    
}


+ (void)sessionStateChanged:(FBSession *)session
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
