//
//  Checkin+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Checkin.h"
#import "RestCheckin.h"
#import "RESTable.h"
@interface Checkin (Rest) <RESTable>

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

- (RestPhoto *)firstPhoto;


+ (Checkin *)checkinWithRestCheckin:(RestCheckin *)restCheckin 
             inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSManagedObject *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                    inManagedObjectContext:(NSManagedObjectContext *)context;
@end
