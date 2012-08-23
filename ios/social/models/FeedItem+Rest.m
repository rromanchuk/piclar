//
//  FeedItem+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "User+Rest.h"
#import "RestComment.h"
#import "Comment+Rest.h"
@implementation FeedItem (Rest)
+ (FeedItem *)feedItemWithRestFeedItem:(RestFeedItem *)restFeedItem
              inManagedObjectContext:(NSManagedObjectContext *)context {
    FeedItem *feedItem; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restFeedItem.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *feedItems = [context executeFetchRequest:request error:&error];
    
    if (!feedItems || ([feedItems count] > 1)) {
        // handle error
    } else if (![feedItems count]) {
        feedItem = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem"
                                                inManagedObjectContext:context];
        [feedItem setManagedObjectWithIntermediateObject:restFeedItem];
    } else {
        feedItem = [feedItems lastObject];
    }
    
    return feedItem;
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestFeedItem *restFeedItem = (RestFeedItem *) intermediateObject;
    self.externalId = [NSNumber numberWithInt:restFeedItem.externalId];
    self.type = restFeedItem.type;
    self.createdAt = restFeedItem.createdAt;
    self.meLiked = [NSNumber numberWithBool:restFeedItem.meLiked];
    self.checkin = [Checkin checkinWithRestCheckin:restFeedItem.checkin inManagedObjectContext:self.managedObjectContext];
    self.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
    self.user = [User userWithRestUser:restFeedItem.user inManagedObjectContext:self.managedObjectContext];
    for (RestComment *restComment in restFeedItem.comments) {
        [self addCommentsObject:[Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext]];
    }
}

- (void)updateFeedItemWithRestFeedItem:(RestFeedItem *)restFeedItem {
    [self setManagedObjectWithIntermediateObject:restFeedItem];
}

- (void)like:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSString *error))onError {
    [RestFeedItem like:self.externalId onLoad:onLoad onError:onError];
}

- (void)createComment:(NSString *)comment
               onLoad:(void (^)(RestComment *restComment))onLoad
              onError:(void (^)(NSString *error))onError {
    [RestFeedItem addComment:self.externalId withComment:comment onLoad:onLoad onError:onError];
}


@end
