//
//  ThreadedUpdates.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "ThreadedUpdates.h"
#import "AppDelegate.h"
#import "RestPlace.h"
#import "Place+Rest.h"
#import "Notification+Rest.h"
#import "RestNotification.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"

#import <FacebookSDK/FacebookSDK.h>



@implementation ThreadedUpdates {
    dispatch_queue_t ostronaut_queue;
}


+ (ThreadedUpdates *)shared
{
    static dispatch_once_t pred;
    static ThreadedUpdates *sharedThreadedUpdates;
    
    dispatch_once(&pred, ^{
        sharedThreadedUpdates = [[ThreadedUpdates alloc] init];
    });
    
    return sharedThreadedUpdates;
}


- (id)init {
    if ((self = [super init])) {
        ostronaut_queue = dispatch_queue_create("com.ostrovok.Ostronaut", NULL);
    }
    return self;
}

- (dispatch_queue_t)getOstronautQueue {
    return ostronaut_queue;
}


- (void)loadSuggestedUsersForUser:(NSNumber *)externalId {
    
    
    NSManagedObjectContext *suggestedUsersContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    suggestedUsersContext.parentContext = self.managedObjectContext;
    
    [suggestedUsersContext performBlock:^{
        [RestUser loadSuggested:externalId onLoad:^(NSSet *users) {
            for (RestUser *user in users) {
                [User userWithRestUser:user inManagedObjectContext:suggestedUsersContext];
            }
            // push to parent
            NSError *error;
            if (![suggestedUsersContext save:&error])
            {
                // handle error
                ALog(@"error %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"error %@", error);
                }
            }];

        } onError:^(NSError *error) {
            
        }];
    }];
}


- (void)loadNotificationsPassivelyForUser:(User *)user {
    
    
    NSManagedObjectContext *notificationFeedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    notificationFeedContext.parentContext = self.managedObjectContext;
    user = [User userWithExternalId:user.externalId inManagedObjectContext:notificationFeedContext];
    
    [notificationFeedContext performBlock:^{
        [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:notificationFeedContext];
                [user addNotificationsObject:notification];
            }
            
            // push to parent
            NSError *error;
            if (![notificationFeedContext save:&error])
            {
                // handle error
                ALog(@"error %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"error %@", error);
                }
             }];
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading notifications %@", error);
        }];
    }];
    
}

- (void)loadFeedItemPassively:(NSNumber*)feedItemId {
    
    NSManagedObjectContext *feedItemContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    feedItemContext.parentContext = self.managedObjectContext;
    
    
    [feedItemContext performBlock:^{
        [RestFeedItem loadByIdentifier:feedItemId onLoad:^(RestFeedItem *restFeedItem) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:feedItemContext];
            [self saveContext:feedItemContext];
            // push to parent
            NSError *error;
            if (![feedItemContext save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"Error saving parent context %@", error);
                }
            }];

        } onError:^(NSError *error) {
            ALog(@"Error updating feedItem %@", error);
        }];
    }];
}

- (void)loadFeedPassively:(NSNumber *)externalId {
    
    
    NSManagedObjectContext *userFeedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    userFeedContext.parentContext = self.managedObjectContext;
    [userFeedContext performBlock:^{
        [RestUser loadFeedByIdentifier:externalId onLoad:^(NSSet *restFeedItems) {
            for (RestFeedItem *restFeedItem in restFeedItems) {
                [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:userFeedContext];
            }
            // push to parent
            NSError *error;
            if (![userFeedContext save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"Error saving parent context %@", error);
                }
            }];
            
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading feed %@", error);
        }];
        
    }];

}
- (void)loadFeedPassively {    
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;
    
    
    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        [RestFeedItem loadFeed:^(NSArray *feedItems) {
            
            for (RestFeedItem *feedItem in feedItems) {
                [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:temporaryContext];
            }
            DLog(@"END OF THREADED FETCH RESULTS");
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading feed %@", error);
        }];

        
        // push to parent
        NSError *error;
        if (![temporaryContext save:&error])
        {
            // handle error
        }
        
        // save parent to disk asynchronously
        [self.managedObjectContext performBlock:^{
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                // handle error
            }
        }];
    }];
}

- (void)loadFollowersPassively:(NSNumber *)externalId {
    NSManagedObjectContext *loadFollowingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    loadFollowingContext.parentContext = self.managedObjectContext;
    
    [loadFollowingContext performBlock:^{
        [RestUser loadFollowingInfo:externalId onLoad:^(RestUser *restUser) {
            
            [User userWithRestUser:restUser inManagedObjectContext:loadFollowingContext];
            NSError *error;
            if (![loadFollowingContext save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"error %@", error);
                } else {
                    
                }
            }];
            
        } onError:^(NSError *error) {
            ALog(@"Error loading following: %@", error);
        }];
        
    }];

}

- (void)loadPlacesPassively {
    if ([Location sharedLocation].isFetchingFromServer)
        return;
    
    [Location sharedLocation].isFetchingFromServer = YES;
    float lat = [[Location sharedLocation].latitude floatValue];
    float lon = [[Location sharedLocation].longitude floatValue];
    
    NSManagedObjectContext *placesContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    placesContext.parentContext = self.managedObjectContext;

    [placesContext performBlock:^{
        [RestPlace searchByLat:lat
                        andLon:lon
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:placesContext];
                            }
                            [Place fetchClosestPlace:[Location sharedLocation] inManagedObjectContext:placesContext];
                            ALog(@"found %d places", [places count]);
                            // push to parent
                            NSError *error;
                            if (![placesContext save:&error])
                            {
                                ALog(@"Error saving temporary context %@", error);
                            }
                            
                            // save parent to disk asynchronously
                            [self.managedObjectContext performBlock:^{
                                NSError *error;
                                if (![self.managedObjectContext save:&error])
                                {
                                    // handle error
                                    ALog(@"Error saving parent context %@", error);
                                }
                            }];

                            [Location sharedLocation].isFetchingFromServer = NO;
                        } onError:^(NSError *error) {
                            DLog(@"Problem searching places: %@", error);
                            [Location sharedLocation].isFetchingFromServer = NO;
                        }priority:NSOperationQueuePriorityVeryLow];
    }];
    
}




- (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            [Flurry logError:@"FAILED_CONTEXT_SAVE" message:[error description] error:error];
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            // There are rare cases where coredata will not know how to merge changes, it's ok to just let this merge fail
            //abort();
        }
    }    
}



- (void)dealloc {
    dispatch_release(ostronaut_queue);

}

@end
