//
//  Photo.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/4/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSData * largeImage;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) Place *place;

@end
