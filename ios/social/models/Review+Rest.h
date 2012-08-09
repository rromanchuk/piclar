//
//  Review+Rest.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import "Review.h"
#import "RESTable.h"
#import "RestComment.h"
@interface Review (Rest) <RESTable>

+ (Review *)reviewWithRestComment:(RestComment *)restComment
             inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
@end
