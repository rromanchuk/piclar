//
//  Comment+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Comment+Rest.h"
#import "RestComment.h"
#import "User+Rest.h"
#import "FeedItem.h"
@implementation Comment (Rest)

+ (Comment *)commentWithRestComment:(RestComment *)restComment 
             inManagedObjectContext:(NSManagedObjectContext *)context {
    
    Comment *comment; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restComment.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *comments = [context executeFetchRequest:request error:&error];
    
    if (!comments || ([comments count] > 1)) {
        // handle error
    } else if (![comments count]) {
        comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                              inManagedObjectContext:context];
        [comment setManagedObjectWithIntermediateObject:restComment];
    } else {
        comment = [comments lastObject];
    }
    
    return comment;

}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestComment *restComment = (RestComment *) intermediateObject;
    DLog(@"CREATING COMMENT COREDATE WITH %@", restComment);
    self.externalId = [NSNumber numberWithInt:restComment.externalId];
    self.comment = restComment.comment; 
    self.createdAt = restComment.createdAt;
    self.user = [User userWithRestUser:restComment.user inManagedObjectContext:self.managedObjectContext];
}

- (void)deleteComment:(void (^)(RestFeedItem *restFeedItem))onLoad
              onError:(void (^)(NSString *error))onError {
    [RestFeedItem deleteComment:self.feedItem.externalId commentExternalId:self.externalId onLoad:onLoad onError:onError];
}

@end
