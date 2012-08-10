//
//  Review+Rest.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import "Review.h"
#import "RESTable.h"
#import "RestReview.h"
@interface Review (Rest) <RESTable>

+ (Review *)reviewWithRestReview:(RestReview *)restReview
             inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
@end
