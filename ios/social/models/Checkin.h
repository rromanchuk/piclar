//
//  Checkin.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, Photo, Place, User;

@interface Checkin : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * userRating;
@property (nonatomic, retain) FeedItem *feedItem;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;
@end

@interface Checkin (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
