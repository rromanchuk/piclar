//
//  RestNotification.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "RestObject.h"
#import "RestUser.h"
#import "RestFeedItem.h"

typedef enum {
    NotificationTypeNewComment   = 1,
    NotificationTypeNewFriend    = 2,
} NotificationType;

@interface RestNotification : RestObject
@property (strong, atomic) NSString *type;
@property (strong, atomic) NSDate *createdAt;
@property NSInteger isRead;
@property NSInteger notificationType;
@property NSInteger feedItemId;
@property BOOL isActive;

@property RestUser *sender;
@property NSString *placeTitle;

+ (NSDictionary *)mapping;
+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSError *error))onError;

+ (void)markAllAsRead:(void (^)(bool status))onLoad
     onError:(void (^)(NSError *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestNotification *restNotification))onLoad
                 onError:(void (^)(NSError *error))onError;

@end
