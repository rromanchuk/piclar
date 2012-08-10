//
//  Review+Rest.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import "Review+Rest.h"
#import "User+Rest.h"

@implementation Review (Rest)
+ (Review *)reviewWithRestReview:(RestReview *)restReview
             inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Review *review;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Review"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restReview.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *reviews = [context executeFetchRequest:request error:&error];
    
    if (!reviews || ([reviews count] > 1)) {
        // handle error
    } else if (![reviews count]) {
        review = [NSEntityDescription insertNewObjectForEntityForName:@"Review"
                                                inManagedObjectContext:context];
        [review setManagedObjectWithIntermediateObject:restReview];
    } else {
        review = [reviews lastObject];
    }
    
    return review;
    
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestReview *restReview = (RestReview *) intermediateObject;
    self.externalId = [NSNumber numberWithInt:restReview.externalId];
    self.review = restReview.review;
    self.createdAt = restReview.createdAt;
}

@end
