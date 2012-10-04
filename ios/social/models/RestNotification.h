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
@interface RestNotification : RestObject
@property (strong, atomic) NSString *type;
@property (strong, atomic) NSDate *createdAt;
@property NSInteger isRead;
@property NSInteger notificationType;
@property RestUser *sender;
@property RestFeedItem *feedItem;
@property NSString *placeTitle;

+ (NSDictionary *)mapping;
+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSString *error))onError;

+ (void)markAllAsRead:(void (^)(bool status))onLoad
     onError:(void (^)(NSString *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestNotification *restNotification))onLoad
                 onError:(void (^)(NSString *error))onError;

@end
