//
//  User+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User+Rest.h"

@implementation User (Rest)
+ (User *)userWithRestUser:(RestUser *)restUser 
    inManagedObjectContext:(NSManagedObjectContext *)context {
    
    User *user;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", restUser.externalId];
   
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
    } else if (![users count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                     inManagedObjectContext:context];
        user.firstname = restUser.firstName;
        user.lastname = restUser.lastName;
        user.externalId = restUser.externalId;
        
    } else {
        user = [users lastObject];
    }

    return user;
}

+ (User *)userWithExternalId:(NSNumber *)externalId 
      inManagedObjectContext:(NSManagedObjectContext *)context {
    User *user;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", externalId];
    
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
        NSLog(@"FOUND MULTIPLE USERS");
    } else if (![users count]) {
        NSLog(@"NO USER FOUND");
    } else {
        NSLog(@"FOUND USER");
        user = [users lastObject];
    }
    
    return user;
}

@end
