//
//  Place.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Photo;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addCheckinsObject:(Checkin *)value;
- (void)removeCheckinsObject:(Checkin *)value;
- (void)addCheckins:(NSSet *)values;
- (void)removeCheckins:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
