//
//  Photo.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Checkin *checkin;
@property (nonatomic, retain) Place *place;

@end
