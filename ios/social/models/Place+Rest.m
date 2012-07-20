

#import "Place+Rest.h"
#import "RestPlace.h"
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
        
        [RestPlace loadByIdentifier:[identifier integerValue]
                             onLoad:^(RestPlace *restPlace) {
                                 [place setManagedObjectWithIntermediateObject:restPlace];
                             } onError:^(NSString *error) {
                                 NSLog(@"");
                             }];
        
        
    } else {
        place = [places lastObject];
    }
    
    return place;
}

#pragma mark - RESTable implementations


- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestPlace *restPlace = (RestPlace *) intermediateObject; 
    self.externalId = [NSNumber numberWithInteger:restPlace.externalId];
    self.title = restPlace.title;
    self.desc = restPlace.desc; 
    self.address = restPlace.address;
}

@end
