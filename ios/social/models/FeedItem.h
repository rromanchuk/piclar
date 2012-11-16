//
//  FeedItem.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/15/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, User;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSNumber * meLiked;
@property (nonatomic, retain) NSDate * sharedAt;
@property (nonatomic, retain) NSNumber * showInFeed;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *liked;
@property (nonatomic, retain) User *user;
@end

@interface FeedItem (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addLikedObject:(User *)value;
- (void)removeLikedObject:(User *)value;
- (void)addLiked:(NSSet *)values;
- (void)removeLiked:(NSSet *)values;

@end
