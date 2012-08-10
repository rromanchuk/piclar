//
//  User.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Comment;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSData * profilePhoto;
@property (nonatomic, retain) NSString * remoteProfilePhotoUrl;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * vkUserId;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *comments;
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

@end
