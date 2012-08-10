//
//  Review.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/10/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Place, User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSString * review;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) Checkin *checkIn;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;

@end
