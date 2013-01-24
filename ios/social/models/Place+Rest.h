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
+ (Place *)placeWithRestPlace:(RestPlace *)restPlace
       inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Place *)placeWithExternalId:(NSNumber *)externalId
        inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;


+ (NSArray *)fetchClosestPlacesToLat:(double)lat andLon:(double)lon inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Place *)fetchClosestPlaceToLat:(double)lat andLon:(double)lon
            inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)updatePlaceWithRestPlace:(RestPlace *)restPlace;
- (Photo *)firstPhoto;
- (NSString *)cityCountryString;

@end
