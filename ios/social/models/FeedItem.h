//
//  FeedItem.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, User;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *user;
@end

@interface FeedItem (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
