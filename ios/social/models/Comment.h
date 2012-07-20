//
//  Comment.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Checkin *checkin;

@end
