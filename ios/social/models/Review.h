//
//  Review.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Place, User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Checkin *checkIn;

@end
