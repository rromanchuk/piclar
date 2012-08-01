//
//  Checkin.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Photo, Place, User;

@interface Checkin : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * favorites;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;
@end

@interface Checkin (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
