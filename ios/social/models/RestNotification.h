//
//  RestNotification.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "RestObject.h"
#import "RestUser.h"

@interface RestNotification : RestObject
@property (strong, atomic) NSString *type;
@property (strong, atomic) NSDate *createdAt;
@property NSInteger isRead;
@property NSInteger notificationType;
@property RestUser *sender;
@property NSString *placeTitle;

+ (NSDictionary *)mapping;
+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSString *error))onError;

+ (void)markAllAsRead:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSString *error))onError;

@end
