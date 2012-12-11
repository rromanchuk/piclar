//
//  NotificationHandler.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/16/12.
//
//

#import "NotificationHandler.h"
#import "UAPushUI.h"
#import "UAPushNotificationHandler.h"
#import "ThreadedUpdates.h"
#import <AudioToolbox/AudioServices.h>
#import "AppDelegate.h"

#import "FeedItem+Rest.h"
#import "RestUser.h"
#import "User.h"
#import "User+Rest.h"

#import "CheckinViewController.h"
@implementation NotificationHandler

+ (NotificationHandler *)shared
{
    static NotificationHandler *notificationHandler;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        notificationHandler = [[NotificationHandler alloc] init];
    });
    
    return notificationHandler;
}



- (void)displayNotificationAlert:(NSString *)alertMessage {
	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UA_PU_TR(@"UA_Notification_Title")
//                                                    message: alertMessage
//                                                   delegate: nil
//                                          cancelButtonTitle: @"OK"
//                                          otherButtonTitles: nil];
//	[alert show];
}

- (void)displayLocalizedNotificationAlert:(NSDictionary *)alertDict {
	
	// The alert is a a dictionary with more details, let's just get the message without localization
	// This should be customized to fit your message details or usage scenario
	//message = [[alertDict valueForKey:@"alert"] valueForKey:@"body"];
	
    UALOG(@"Got an alert with a body.");
    
//    NSString *body = [alertDict valueForKey:@"body"];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UA_PU_TR(@"UA_Notification_Title")
//                                                    message: body
//                                                   delegate: nil
//                                          cancelButtonTitle: @"OK"
//                                          otherButtonTitles: nil];
	//[alert show];
}

- (void)playNotificationSound:(NSString *)sound {
    
    if (sound) {
        
        // Note: The default sound is not available in the app.
        //
        // From http://developer.apple.com/library/ios/#documentation/AudioToolbox/Reference/SystemSoundServicesReference/Reference/reference.html :
        // System-supplied alert sounds and system-supplied user-interface sound effects are not available to your iOS application.
        // For example, using the kSystemSoundID_UserPreferredAlert constant as a parameter to the AudioServicesPlayAlertSound
        // function will not play anything.
        
        SystemSoundID soundID;
        NSString *path = [[NSBundle mainBundle] pathForResource:[sound stringByDeletingPathExtension]
                                                         ofType:[sound pathExtension]];
        if (path) {
            DLog(@"Received an alert with a sound: %@", sound);
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
            AudioServicesPlayAlertSound(soundID);
        } else {
            DLog(@"Received an alert with a sound that cannot be found the application bundle: %@", sound);
        }
        
    } else {
        
        // Vibrates on supported devices, on others, does nothing
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    }
    
}

//**
//* Called when an alert notification is received.
//* @param alertMessage a simple string to be displayed as an alert
//*/
//- (void)displayNotificationAlert:(NSString *)alertMessage;
//
///**
// * Called when an alert notification is received with additional localization info.
// * @param alertDict a dictionary containing the alert and localization info
// */
//- (void)displayLocalizedNotificationAlert:(NSDictionary *)alertDict;
//
///**
// * Called when a push notification is received with a sound associated
// * @param sound the sound to play
// */
//- (void)playNotificationSound:(NSString *)sound;
//
///**
// * Called when a push notification is received with a custom payload
// * @param notification basic information about the notification
// * @param customPayload user-defined custom payload
// */
//- (void)handleNotification:(NSDictionary *)notification withCustomPayload:(NSDictionary *)customPayload;
//
///**
// * Called when a push notification is received with a badge number
// * @param badgeNumber The badge number to display
// */
//- (void)handleBadgeUpdate:(int)badgeNumber;
//
///**
// * Called when a push notification is received when the application is in the background
// * @param notification the push notification
// */
//- (void)handleBackgroundNotification:(NSDictionary *)notification;
//



- (void)handleBadgeUpdate:(int)badgeNumber {
	ALog(@"Received an alert with a new badge");
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
    [SVProgressHUD showSuccessWithStatus:@"Updating badge number"];
}

- (void)handleNotification:(NSDictionary *)notification withCustomPayload:(NSDictionary *)customData {
    ALog(@"Received an alert with a custom payload %@ and notification %@", customData, notification);
    // Update notifications
    [[ThreadedUpdates shared] loadNotificationsPassivelyForUser:self.currentUser];
	// Do something with your customData JSON, then entire notification is also available
    NSString *_type = [[customData objectForKey:@"extra"] objectForKey:@"type"];
    if ([_type isEqualToString:@"notification_approved"]) {
        [self.currentUser updateFromServer];
        [self.approvalDelegate approvalStatusDidChange];
        return;
    }
    
    [self.delegate presentIncomingNotification:customData notification:notification];
}

- (void)handleBackgroundNotification:(NSDictionary *)notification {
    ALog(@"The application resumed from a notification. %@", notification);
   
    [self.delegate presentNotificationApplicationLaunch:notification];
}

@end
