//
//  Notification.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/3/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, User;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * notificationType;
@property (nonatomic, retain) NSString * placeTitle;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) FeedItem *feedItem;

@end
