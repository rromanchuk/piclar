//
//  Photo.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
