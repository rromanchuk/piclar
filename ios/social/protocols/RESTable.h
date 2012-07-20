//
//  RESTable.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"

@protocol RESTable <NSObject>
@required
- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
+ (NSManagedObject *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                              inManagedObjectContext:(NSManagedObjectContext *)context;
@end
