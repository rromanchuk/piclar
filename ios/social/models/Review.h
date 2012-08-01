//
//  Review.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, User;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;

@end
