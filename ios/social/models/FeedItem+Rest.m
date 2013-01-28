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
#import "Notification+Rest.h"
@implementation FeedItem (Rest)

- (void)awakeFromFetch {
    [super awakeFromFetch];
    //ALog(@"awake from fetch %d", [self.liked count]);
    [self setPrimitiveValue:[NSNumber numberWithInteger:[self.liked count]] forKey:@"numberOfLikes"];
}

- (void)setNumberOfLikes:(NSNumber *)numberOfLikes {
    [self willChangeValueForKey:@"numberOfLikes"];
    [self setPrimitiveValue:numberOfLikes forKey:@"numberOfLikes"];
    [self didChangeValueForKey:@"numberOfLikes"];
}

+ (FeedItem *)feedItemWithRestFeedItem:(RestFeedItem *)restFeedItem
              inManagedObjectContext:(NSManagedObjectContext *)context {
    FeedItem *feedItem; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restFeedItem.externalId]];
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
        [feedItem updateFeedItemWithRestFeedItem:restFeedItem];
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

// We don't actually use a coredata relationship, but we store the fk (feedItemId) so we are responsible 
- (void)deactivateRelatedNotifications {
    NSArray *notifications = [Notification notificatonsWithFeedItemId:self.externalId inManagedObjectContext:self.managedObjectContext];
    for (Notification *notification in notifications) {
        notification.isActive = [NSNumber numberWithBool:NO];
    }
}

- (void)deactivate {
    self.isActive = [NSNumber numberWithBool:NO];
    self.checkin.isActive = [NSNumber numberWithBool:NO];;
    [self deactivateRelatedNotifications];
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestFeedItem *restFeedItem = (RestFeedItem *) intermediateObject;
#warning clean this up
    if (!restFeedItem.isActive) {
        self.isActive = [NSNumber numberWithBool:restFeedItem.isActive];
        self.sharedAt = restFeedItem.sharedAt;
        self.externalId = [NSNumber numberWithInt:restFeedItem.externalId];
        return;
    }
    self.externalId = [NSNumber numberWithInt:restFeedItem.externalId];
    self.type = restFeedItem.type;
    self.createdAt = restFeedItem.createdAt;
    self.sharedAt = restFeedItem.sharedAt;
    self.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
    self.isActive = [NSNumber numberWithBool:restFeedItem.isActive];
    self.checkin = [Checkin checkinWithRestCheckin:restFeedItem.checkin inManagedObjectContext:self.managedObjectContext];
    self.user = [User userWithRestUser:restFeedItem.user inManagedObjectContext:self.managedObjectContext];
    self.showInFeed = [NSNumber numberWithBool:restFeedItem.showInFeed];
    // Add comments
    for (RestComment *restComment in restFeedItem.comments) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
#warning investigate this crash where comment is nil (probably because they aren't synced yet)
        if (comment) {
            [self addCommentsObject:comment];
        }
    }
    // Add users who liked
    for (RestUser *restUser in restFeedItem.liked) {
        [self addLikedObject:[User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext]];
    }
}

- (void)updateFeedItemWithRestFeedItem:(RestFeedItem *)restFeedItem {
    [self setManagedObjectWithIntermediateObject:restFeedItem];
    [self syncLikesWithRestObject:restFeedItem];
    [self syncCommentsWithRestObject:restFeedItem];
}

- (void)like:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSError *error))onError {
    [RestFeedItem like:self.externalId onLoad:onLoad onError:onError];
}

- (void)unlike:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSError *error))onError {
    [RestFeedItem unlike:self.externalId onLoad:onLoad onError:onError];
}

- (void)createComment:(NSString *)comment
               onLoad:(void (^)(RestComment *restComment))onLoad
              onError:(void (^)(NSError *error))onError {
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

- (void)syncCommentsWithRestObject:(RestFeedItem *)restFeedItem {
    DLog(@"Making sure comments are synced");
    if ([self.comments count] != [restFeedItem.comments count]) {
        DLog(@"Comments are not synchronized");
        NSMutableSet *commentsFromServer = [[NSMutableSet alloc] init];
        for (RestComment *restComment in restFeedItem.comments) {
            [commentsFromServer addObject:[Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext]];
        }
        DLog(@"comments from server are %@", commentsFromServer);
        DLog(@"comments from coredate are %@", self.comments);
        NSMutableSet *commentsFromCoreData = [NSMutableSet setWithSet:self.comments];
        //[likersFromServer minusSet:likersFromCoreData];
        [commentsFromCoreData minusSet:commentsFromServer];
        DLog(@"after minus set (commentsFromCoreData %@", commentsFromCoreData);
        DLog(@"after minus set (commentsFromServer %@", commentsFromServer);
        
        [self removeComments:commentsFromCoreData];
        
    }
}


//- (NSNumber *)numberOfLikes {
//    return [NSNumber numberWithInteger:[self.liked count]];
//}

@end
