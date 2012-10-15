//
//  User.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, FeedItem, Notification, User, UserSettings;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * checkinsCount;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSData * profilePhoto;
@property (nonatomic, retain) NSNumber * registrationStatus;
@property (nonatomic, retain) NSString * remoteProfilePhotoUrl;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * vkUserId;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *feedItems;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *following;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) NSSet *notificationsCreated;
@property (nonatomic, retain) UserSettings *settings;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCheckinsObject:(Checkin *)value;
- (void)removeCheckinsObject:(Checkin *)value;
- (void)addCheckins:(NSSet *)values;
- (void)removeCheckins:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFeedItemsObject:(FeedItem *)value;
- (void)removeFeedItemsObject:(FeedItem *)value;
- (void)addFeedItems:(NSSet *)values;
- (void)removeFeedItems:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingObject:(User *)value;
- (void)removeFollowingObject:(User *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addNotificationsCreatedObject:(Notification *)value;
- (void)removeNotificationsCreatedObject:(Notification *)value;
- (void)addNotificationsCreated:(NSSet *)values;
- (void)removeNotificationsCreated:(NSSet *)values;

@end
