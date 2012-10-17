//
//  FeedItem.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, Notification, User;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSNumber * meLiked;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *liked;
@end

@interface FeedItem (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addLikedObject:(User *)value;
- (void)removeLikedObject:(User *)value;
- (void)addLiked:(NSSet *)values;
- (void)removeLiked:(NSSet *)values;

@end
