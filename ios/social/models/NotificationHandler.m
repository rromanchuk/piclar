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

#import <AudioToolbox/AudioServices.h>

@implementation NotificationHandler
- (void)displayNotificationAlert:(NSString *)alertMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UA_PU_TR(@"UA_Notification_Title")
                                                    message: alertMessage
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
	[alert show];
}

- (void)displayLocalizedNotificationAlert:(NSDictionary *)alertDict {
	
	// The alert is a a dictionary with more details, let's just get the message without localization
	// This should be customized to fit your message details or usage scenario
	//message = [[alertDict valueForKey:@"alert"] valueForKey:@"body"];
	
    UALOG(@"Got an alert with a body.");
    
    NSString *body = [alertDict valueForKey:@"body"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UA_PU_TR(@"UA_Notification_Title")
                                                    message: body
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
	[alert show];
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

- (void)handleBadgeUpdate:(int)badgeNumber {
	DLog(@"Received an alert with a new badge");
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void)handleNotification:(NSDictionary *)notification withCustomPayload:(NSDictionary *)customData {
    ALog(@"Received an alert with a custom payload");
	
	// Do something with your customData JSON, then entire notification is also available
	
}

- (void)handleBackgroundNotification:(NSDictionary *)notification {
    ALog(@"The application resumed from a notification.");
	
	// Do something when launched from the background via a notification
	
}

@end
