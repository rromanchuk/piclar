//
//  Place+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"
#import "RestPlace.h"

@interface Place (Rest)
+ (Place *)placeWithRestPlace:(RestPlace *)restPlace
             inManagedObjectContext:(NSManagedObjectContext *)context;
@end
