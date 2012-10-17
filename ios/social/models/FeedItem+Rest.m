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

+ (FeedItem *)feedItemWithExternalId:(NSNumber *)externalId
              inManagedObjectContext:(NSManagedObjectContext *)context {
    FeedItem *feedItem;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@",externalId];
    
    NSError *error = nil;
    NSArray *feedItems = [context executeFetchRequest:request error:&error];
    
    if (!feedItems || ([feedItems count] > 1)) {
        // handle error
        feedItem = nil;
    } else if (![feedItems count]) {
        feedItem = nil;
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
    self.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
    self.checkin = [Checkin checkinWithRestCheckin:restFeedItem.checkin inManagedObjectContext:self.managedObjectContext];
    self.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
    self.user = [User userWithRestUser:restFeedItem.user inManagedObjectContext:self.managedObjectContext];
    // Add comments
    for (RestComment *restComment in restFeedItem.comments) {
        [self addCommentsObject:[Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext]];
    }
    // Add users who liked
    for (RestUser *restUser in restFeedItem.liked) {
        [self addLikedObject:[User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext]];
    }
}

- (void)updateFeedItemWithRestFeedItem:(RestFeedItem *)restFeedItem {
    [self setManagedObjectWithIntermediateObject:restFeedItem];
}

- (void)like:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSString *error))onError {
    [RestFeedItem like:self.externalId onLoad:onLoad onError:onError];
}

- (void)unlike:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSString *error))onError {
    [RestFeedItem unlike:self.externalId onLoad:onLoad onError:onError];
}

- (void)createComment:(NSString *)comment
               onLoad:(void (^)(RestComment *restComment))onLoad
              onError:(void (^)(NSString *error))onError {
    [RestFeedItem addComment:self.externalId withComment:comment onLoad:onLoad onError:onError];
}

- (void)syncLikesWithRestObject:(RestFeedItem *)restFeedItem {
    DLog(@"Making sure likes are synced");
    if ([self.liked count] != [restFeedItem.liked count]) {
        DLog(@"Likes are not synchronized");
        NSMutableSet *likersFromServer = [[NSMutableSet alloc] init];
        for (RestUser *restUser in restFeedItem.liked) {
            [likersFromServer addObject:[User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext]];
        }
        DLog(@"likers from server are %@", likersFromServer);
        DLog(@"likers from coredate are %@", self.liked);
        NSMutableSet *likersFromCoreData = [NSMutableSet setWithSet:self.liked];
        //[likersFromServer minusSet:likersFromCoreData];
        [likersFromCoreData minusSet:likersFromServer];
        DLog(@"after minus set (likersFromCoreData %@", likersFromCoreData);
        DLog(@"after minus set (likersFromServer %@", likersFromServer);

        [self removeLiked:likersFromCoreData];

    }
    
    
}


@end
