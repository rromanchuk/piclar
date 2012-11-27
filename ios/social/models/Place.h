//
//  Place.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/27/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Photo;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * typeId;
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
