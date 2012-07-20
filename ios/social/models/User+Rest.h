//
//  User+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "RestUser.h"

@interface User (Rest)

- (void)setWithRestPlace:(RestPlace *)restPlace;

+ (User *)userWithRestUser:(RestUser *)restUser 
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithExternalId:(NSNumber *)externalId 
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
