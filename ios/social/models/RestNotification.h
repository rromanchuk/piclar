//
//  RestNotification.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "RestObject.h"

@interface RestNotification : RestObject
@property (strong, atomic) NSString *type;
@property (strong, atomic) NSDate *createdAt;
@property NSInteger isRead;
@property NSInteger notificationType;
@property RestUser *sender;

+ (NSDictionary *)mapping;
+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSString *error))onError;

@end
