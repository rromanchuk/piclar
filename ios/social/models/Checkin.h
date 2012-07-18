//
//  Checkin.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, User;

@interface Checkin : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) User *user;

@end
