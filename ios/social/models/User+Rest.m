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
    request.predicate = [NSPredicate predicateWithFormat:@"firstname = %@", restUser.firstName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
    } else if (![users count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                     inManagedObjectContext:context];
        user.firstname = restUser.firstName;
        user.lastname = restUser.lastName;
    } else {
        user = [users lastObject];
    }

    return user;
}

@end
