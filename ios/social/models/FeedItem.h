//
//  FeedItem.h
//  FancyTrace
//
//  Created by Ryan Romanchuk on 1/31/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Photo, Place, User;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * meLiked;
@property (nonatomic, retain) NSNumber * numberOfLikes;
@property (nonatomic, retain) NSNumber * placeId;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * review;
@property (nonatomic, retain) NSDate * sharedAt;
@property (nonatomic, retain) NSNumber * showInFeed;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * thumbPhotoUrl;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *liked;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) Place *place;
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
