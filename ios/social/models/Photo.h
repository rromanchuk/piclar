//
//  Photo.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * is_deleted;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Place *place;

@end
