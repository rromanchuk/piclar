//
//  Place+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"
#import "RestPlace.h"
#import "RESTable.h"
#import "Location.h"
@interface Place (Rest) <RESTable>

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

+ (Place *)placeWithRestPlace:(RestPlace *)restPlace
             inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)fetchClosestPlace:(Location *)location
            inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)updatePlaceWithRestPlace:(RestPlace *)restPlace;
- (void)pushToServer;
- (Photo *)firstPhoto;
- (NSString *)cityCountryString;

@end
