//
//  NotificationHandler.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import "UAPush.h"
#import "User.h"
@protocol NotificationDisplayModalDelegate;
@interface NotificationHandler : NSObject <UAPushNotificationDelegate>
@property (strong, nonatomic) User *currentUser;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <NotificationDisplayModalDelegate> delegate;
+ (NotificationHandler *)shared;

@end



@protocol NotificationDisplayModalDelegate <NSObject>

@required
- (void)presentNotificationApplicationLaunch:(NSDictionary *)customData;
- (void)presentIncomingNotification:(NSDictionary *)customData notification:(NSDictionary *)notification;

@optional

@end