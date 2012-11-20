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

static int activeThreads = 0;


@implementation ThreadedUpdates {
    BOOL isBlocked;
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
        isBlocked = NO;
        ostronaut_queue = dispatch_queue_create("com.ostrovok.Ostronaut", NULL);
    }
    return self;
}

- (dispatch_queue_t)getOstronautQueue {
    return ostronaut_queue;
}

- (void)loadNotificationsPassivelyForUser:(User *)user {
    
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;
    
    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        User *newUser = [User userWithExternalId:user.externalId inManagedObjectContext:temporaryContext];
        [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                DLog(@"notification %@", restNotification);
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:temporaryContext];
                [newUser addNotificationsObject:notification];
            }
        } onError:^(NSString *error) {
            ALog(@"Problem loading notifications %@", error);
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

- (void)loadFeedItemPassively:(NSNumber*)feedItemId {
    [self incrementThreadCount];
    dispatch_async(ostronaut_queue, ^{
        
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self newContext];
        
        [RestFeedItem loadByIdentifier:feedItemId onLoad:^(RestFeedItem *restFeedItem) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:newMoc];
            [self saveContext:newMoc];
            
        } onError:^(NSString *error) {
            
        }];
        
        
    });
    
}

- (void)loadFeedPassively:(NSNumber *)externalId {
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;
    
    
    
    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        [RestUser loadFeedByIdentifier:externalId onLoad:^(NSSet *restFeedItems) {
            for (RestFeedItem *restFeedItem in restFeedItems) {
                [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:temporaryContext];
            }
            
        } onError:^(NSString *error) {
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
            
        } onError:^(NSString *error) {
            ALog(@"Problem loading feed %@", error);
        }
                      withPage:1];

        
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

- (void)loadFollowingPassively:(NSNumber *)externalId {
   
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;

    
    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        User *user = [User userWithExternalId:externalId inManagedObjectContext:temporaryContext];
        [RestUser loadFollowing:externalId onLoad:^(NSSet *users) {
            [user removeFollowing:user.following];
            NSMutableSet *following = [[NSMutableSet alloc] init];
            for (RestUser *friend_restUser in users) {
                User *_user = [User userWithRestUser:friend_restUser inManagedObjectContext:temporaryContext];
                [following addObject:_user];
            }
            [user addFollowing:following];
            
            
            // push to parent
            NSError *error;
            if (![temporaryContext save:&error])
            {
                // handle error
                ALog(@"Error loading following %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"Error loading following %@", error);
                }
            }];

        } onError:^(NSString *error) {
            ALog(@"Error loading following %@", error);
        }];

    }];
}


- (void)loadFollowersPassively:(NSNumber *)externalId {
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;

    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        User *user = [User userWithExternalId:externalId inManagedObjectContext:temporaryContext];
        [RestUser loadFollowers:externalId onLoad:^(NSSet *users) {
            [user removeFollowers:user.followers];
            NSMutableSet *followers = [[NSMutableSet alloc] init];
            for (RestUser *friend_restUser in users) {
                User *_user = [User userWithRestUser:friend_restUser inManagedObjectContext:temporaryContext];
                [followers addObject:_user];
            }
            [user addFollowers:followers];
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

            
        } onError:^(NSString *error) {
            DLog(@"Error loading followers %@", error);
            
        }];

    }];
}





- (void)loadPlacesPassively {
    [self incrementThreadCount];
    float lat = [Location sharedLocation].latitude;
    float lon = [Location sharedLocation].longitude;
    dispatch_async(ostronaut_queue, ^{
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [self newContext];
            
        [RestPlace searchByLat:lat
                        andLon:lon
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:newMoc];
                            }
                            [Place fetchClosestPlace:[Location sharedLocation] inManagedObjectContext:newMoc];
                            [self saveContext:newMoc];
                            
                        } onError:^(NSString *error) {
                            DLog(@"Problem searching places: %@", error);
                        }priority:NSOperationQueuePriorityVeryLow];
        
    });
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
    
    [self performSelectorOnMainThread:@selector(decrementThreadCount)
                           withObject:nil
                        waitUntilDone:NO];
}

- (NSManagedObjectContext *)newContext {
    AppDelegate *theDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] init];
    [newMoc setPersistentStoreCoordinator:[theDelegate persistentStoreCoordinator]];
    
    // Register for context save changes notification
    NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self
               selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:newMoc];
    
    return newMoc;
}

- (void)mergeChanges:(NSNotification *)notification
{
    ALog(@"Merging changes back on to the main thread");
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    
//    if (![NSThread isMainThread]) {
//        
//        [self performSelectorOnMainThread:@selector(decrementThreadCount)
//                               withObject:nil
//                            waitUntilDone:NO];
//    } else {
//        [self decrementThreadCount];
//    }

    

}

- (void)decrementThreadCount {
    activeThreads = MAX(activeThreads - 1, 0);
    ALog(@"Decremented. thread count now: %d", activeThreads);

    if (activeThreads == 0) {
        ALog(@"active threads are ZERO!! remove notification");
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:nil];

    }
}

- (void)incrementThreadCount {
    activeThreads++;
    ALog(@"Incremented. thread count now %d", activeThreads);
}


- (void)dealloc {
    dispatch_release(ostronaut_queue);

}

@end
