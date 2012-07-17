//
//  Checkin+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Checkin.h"
#import "RestCheckin.h"
@interface Checkin (Rest)

+ (Checkin *)checkinWithRestCheckin:(RestCheckin *)restCheckin 
             inManagedObjectContext:(NSManagedObjectContext *)context;

@end
