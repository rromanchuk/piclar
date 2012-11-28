

#import <Foundation/Foundation.h>
#import "Place+Rest.h"
#import "RestPlace.h"
#import "RestCheckin.h"
#import "Photo+Rest.h"
#import "Checkin+Rest.h"
@implementation Place (Rest)

// Find or create the object with our intermediate representation of a place from the server. 
+ (Place *)placeWithRestPlace:(RestPlace *)restPlace
           inManagedObjectContext:(NSManagedObjectContext *)context {
    Place *place; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInteger:restPlace.externalId]];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    
    if (!places || ([places count] > 1)) {
        // handle error
    } else if (![places count]) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                             inManagedObjectContext:context];
        
        [place setManagedObjectWithIntermediateObject:restPlace];
    } else {
        place = [places lastObject];
        [place setManagedObjectWithIntermediateObject:restPlace];
    }
    
    return place;
}

+ (Place *)placeWithExternalId:(NSNumber *)externalId
      inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Place *place;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@",externalId];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    if (!places || ([places count] > 1)) {
        // handle error
        place = nil;
    } else if (![places count]) {
        place = nil;
    } else {
        place = [places lastObject];
    }
    
    return place;
}


// Find or create a place with identifer. If the object does not yet exist in coredata fetch
// it down from the server and set setup the object. 
+ (Place *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                    inManagedObjectContext:(NSManagedObjectContext *)context {
    Place *place;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", identifier];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    
    if (!places || ([places count] > 1)) {
        // handle error
    } else if (![places count]) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                              inManagedObjectContext:context];
        
        [RestPlace loadByIdentifier:identifier
                             onLoad:^(RestPlace *restPlace) {
                                 [place setManagedObjectWithIntermediateObject:restPlace];
                             } onError:^(NSError *error) {
                                 DLog(@"");
                             }];
        
        
    } else {
        place = [places lastObject];
    }
    
    return place;
}

#pragma mark - RESTable implementations


- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestPlace *restPlace = (RestPlace *) intermediateObject; 
    for (RestCheckin *checkin in restPlace.checkins) {
        [self addCheckinsObject:[Checkin checkinWithRestCheckin:checkin     inManagedObjectContext:self.managedObjectContext]];
    }
    self.externalId = [NSNumber numberWithInteger:restPlace.externalId];
    self.title = restPlace.title;
    self.cityName = restPlace.cityName;
    self.countryName = restPlace.countryName;
    self.desc = restPlace.desc; 
    self.address = restPlace.address;
    self.rating = [NSNumber numberWithInt:restPlace.rating];
    self.type = restPlace.type;
    self.lat = [NSNumber numberWithFloat:restPlace.lat];
    self.lon = [NSNumber numberWithFloat:restPlace.lon];
    self.typeId = [NSNumber numberWithInt:restPlace.typeId];
}


+ (NSArray *)fetchClosestPlaces:(Location *)location inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    float latMax = location.latitude + 0.09;
    float latMin = location.latitude - 0.09;
    float lngMax = location.longitude + 0.09;
    float lngMin = location.longitude - 0.09;
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"lat > %f and lat < %f and lon > %f and lon < %f",
                              latMin, latMax, lngMin, lngMax];
    DLog(@"lat > %f and lat < %f and lon > %f and lon < %f", latMin, latMax, lngMin, lngMax);
    request.predicate = predicate;
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    for (Place *place in places) {
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[place.lat doubleValue] longitude:[place.lon doubleValue]];
        place.distance = [NSNumber numberWithDouble:[targetLocation distanceFromLocation:location.locationManager.location]];
    }
    
    NSSortDescriptor *sortingBasedOnDistance = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSArray *sortedArray = [places sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortingBasedOnDistance, nil]];
    return sortedArray;

}

+ (Place *)fetchClosestPlace:(Location *)location
                inManagedObjectContext:(NSManagedObjectContext *)context{
    
    Place *place;
    NSArray *places = [Place fetchClosestPlaces:location inManagedObjectContext:context];
    if ([places count] > 0) {
        place = [places objectAtIndex:0];
    }
    return place;
}

- (void)updatePlaceWithRestPlace:(RestPlace *)restPlace {
    [self setManagedObjectWithIntermediateObject:restPlace];
}

- (Photo *)firstPhoto {
    return [self.photos anyObject];
}

- (NSString *)cityCountryString {
    NSString *outString;
    if (self.cityName && self.countryName) {
        outString = [NSString stringWithFormat:@"%@, %@", self.cityName, self.countryName];
    } else if (self.countryName) {
        outString = self.countryName;
    } else if (self.cityName) {
        outString = self.cityName;
    }
    return outString;

}




@end
