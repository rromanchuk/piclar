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

@implementation ThreadedUpdates

+ (ThreadedUpdates *)shared
{
    static dispatch_once_t pred;
    static ThreadedUpdates *sharedThreadedUpdates;
    
    dispatch_once(&pred, ^{
        sharedThreadedUpdates = [[ThreadedUpdates alloc] init];
    });
    
    return sharedThreadedUpdates;
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
            [suggestedUsersContext save:&error];
                      
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
               
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
            [notificationFeedContext save:&error];
                       
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
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
            // push to parent
            NSError *error;
            [feedItemContext save:&error];
        
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];

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
            [userFeedContext save:&error];
                
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
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
            NSError *error;
            [temporaryContext save:&error];
            
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
            }];
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading feed %@", error);
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
            [loadFollowingContext save:&error];
           
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
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
                            [placesContext save:&error];
                            
                            // save parent to disk asynchronously
                            [self.managedObjectContext performBlock:^{
                                NSError *error;
                                [self.managedObjectContext save:&error];
                                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                [sharedAppDelegate writeToDisk];
                            }];

                            [Location sharedLocation].isFetchingFromServer = NO;
                        } onError:^(NSError *error) {
                            DLog(@"Problem searching places: %@", error);
                            [Location sharedLocation].isFetchingFromServer = NO;
                        }priority:NSOperationQueuePriorityVeryLow];
    }];
    
}

@end
