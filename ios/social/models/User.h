//
//  User.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment, Review;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSData * profilePhoto;
@property (nonatomic, retain) NSString * remoteProfilePhotoUrl;
@property (nonatomic, retain) NSString * vkUserId;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *reviews;
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

- (void)addReviewsObject:(Review *)value;
- (void)removeReviewsObject:(Review *)value;
- (void)addReviews:(NSSet *)values;
- (void)removeReviews:(NSSet *)values;

@end
