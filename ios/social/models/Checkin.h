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

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Place *place;

@end
