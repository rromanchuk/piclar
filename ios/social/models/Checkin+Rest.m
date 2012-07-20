//
//  Checkin+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Checkin+Rest.h"

@implementation Checkin (Rest)

+ (Checkin *)checkinWithRestCheckin:(RestCheckin *)restCheckin 
             inManagedObjectContext:(NSManagedObjectContext *)context {
    Checkin *checkin; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    //request.predicate = [NSPredicate predicateWithFormat:@"firstname = %@", restUser.firstName];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *checkins = [context executeFetchRequest:request error:&error];
    
    if (!checkins || ([checkins count] > 1)) {
        // handle error
    } else if (![checkins count]) {
        checkin = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin"
                                             inManagedObjectContext:context];
        [checkin setManagedObjectWithIntermediateObject:restCheckin];
    } else {
        checkin = [checkins lastObject];
    }
        
    return checkin;
}

+ (NSManagedObject *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                              inManagedObjectContext:(NSManagedObjectContext *)context {
    Checkin *checkin;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", identifier];
    
    NSError *error = nil;
    NSArray *checkins = [context executeFetchRequest:request error:&error];
    
    if (!checkins || ([checkins count] > 1)) {
        // handle error
    } else if (![checkins count]) {
        checkin = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin"
                                              inManagedObjectContext:context];
        
        [RestCheckin loadByIdentifer:identifier onLoad:^(RestCheckin *restCheckin) {
            [checkin setManagedObjectWithIntermediateObject:restCheckin];
            NSLog(@"bla");
        } onError:^(NSString *error) {
            NSLog(@"BLAH");
        }];
        
    } else {
        checkin = [checkins lastObject];
    }
    
    return checkin;
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestCheckin *restCheckin = (RestCheckin *) intermediateObject; 
    self.externalId = [NSNumber numberWithInt:restCheckin.externalId];
    self.createdAt = restCheckin.createdAt;
    self.comment = restCheckin.comment; 
}
@end
