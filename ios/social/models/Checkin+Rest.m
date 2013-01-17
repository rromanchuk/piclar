//
//  Checkin+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Checkin+Rest.h"
#import "Place+Rest.h"
#import "User+Rest.h"
#import "Photo+Rest.h"
@implementation Checkin (Rest)

+ (Checkin *)checkinWithRestCheckin:(RestCheckin *)restCheckin 
             inManagedObjectContext:(NSManagedObjectContext *)context {
    Checkin *checkin; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restCheckin.externalId]];
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
        [checkin setManagedObjectWithIntermediateObject:restCheckin];
    }
        
    return checkin;
}



- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestCheckin *restCheckin = (RestCheckin *) intermediateObject;
    if (!restCheckin.isActive) {
        self.isActive = [NSNumber numberWithBool:restCheckin.isActive];
        self.externalId = [NSNumber numberWithInt:restCheckin.externalId];
        return;
    }

    self.externalId = [NSNumber numberWithInt:restCheckin.externalId];
    self.feedItemId = [NSNumber numberWithInteger:restCheckin.feedItemId];
    self.personId = [NSNumber numberWithInteger:restCheckin.personId];
    self.placeId = [NSNumber numberWithInteger:restCheckin.placeId];
    
    self.createdAt = restCheckin.createdAt;
    self.review = restCheckin.review;
    self.userRating = [NSNumber numberWithInt:restCheckin.userRating];
    self.isActive = [NSNumber numberWithBool:restCheckin.isActive];

    if (restCheckin.place)
        self.place = [Place placeWithRestPlace:restCheckin.place inManagedObjectContext:self.managedObjectContext];
    if (restCheckin.user)
        self.user = [User userWithRestUser:restCheckin.user inManagedObjectContext:self.managedObjectContext];
    
    // Add any photos related to the checkin
    for (RestPhoto *photo in restCheckin.photos) {
        [self addPhotosObject:[Photo photoWithRestPhoto:photo inManagedObjectContext:self.managedObjectContext]];
    }
}

- (Photo *)firstPhoto {
    return [self.photos anyObject];
}



@end
