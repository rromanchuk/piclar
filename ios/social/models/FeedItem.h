//
//  FeedItem.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, User;

@interface FeedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Checkin *checkin;
@end

@interface FeedItem (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
