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
#import "RestUser.h"
@protocol NotificationDisplayModalDelegate;
@protocol ApprovalNotificationDelegate;

@interface NotificationHandler : NSObject <UAPushNotificationDelegate>
@property (strong, nonatomic) User *currentUser;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <NotificationDisplayModalDelegate> delegate;
@property (weak, nonatomic) id <ApprovalNotificationDelegate> approvalDelegate;

+ (NotificationHandler *)shared;

@end



@protocol NotificationDisplayModalDelegate <NSObject>

@required
- (void)presentNotificationApplicationLaunch:(NSDictionary *)customData;
- (void)presentIncomingNotification:(NSDictionary *)customData notification:(NSDictionary *)notification;

@optional

@end


@protocol ApprovalNotificationDelegate <NSObject>

@required
- (void)approvalStatusDidChange;


@optional

@end