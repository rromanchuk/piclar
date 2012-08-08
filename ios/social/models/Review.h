//
//  Review.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;

@end
