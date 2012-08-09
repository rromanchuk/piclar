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
+ (Review *)reviewWithRestComment:(RestComment *)restComment
             inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Review *review;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Review"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restComment.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *reviews = [context executeFetchRequest:request error:&error];
    
    if (!reviews || ([reviews count] > 1)) {
        // handle error
    } else if (![reviews count]) {
        review = [NSEntityDescription insertNewObjectForEntityForName:@"Review"
                                                inManagedObjectContext:context];
        [review setManagedObjectWithIntermediateObject:restComment];
    } else {
        review = [reviews lastObject];
    }
    
    return review;
    
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestComment *restComment = (RestComment *) intermediateObject;
    NSLog(@"CREATING REVIEW COREDATE WITH %@", restComment);
    self.externalId = [NSNumber numberWithInt:restComment.externalId];
    self.comment = restComment.comment;
    self.createdAt = restComment.createdAt;
    self.user = [User userWithRestUser:restComment.user inManagedObjectContext:self.managedObjectContext];
}

@end
