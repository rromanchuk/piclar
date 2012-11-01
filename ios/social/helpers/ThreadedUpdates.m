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

@implementation ThreadedUpdates

- (id)initWithContext:(NSManagedObjectContext *)context {
    if ((self = [super init])) {
        self.managedObjectContext = context;
    }
    return self;
}


- (void)loadNotificationsPassivelyForUser:(User *)user {
    dispatch_queue_t request_queue = dispatch_queue_create("com.ostrovok.Ostronaut.loadNotificationsPassivelyForUser", NULL);
    dispatch_async(request_queue, ^{
        AppDelegate *theDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] init];
        [newMoc setPersistentStoreCoordinator:[theDelegate persistentStoreCoordinator]];
        
        // Register for context save changes notification
        NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
        [notify addObserver:self
                   selector:@selector(mergeChanges:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:newMoc];
        
        [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                DLog(@"notification %@", restNotification);
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
                [user addNotificationsObject:notification];
            }
            [self saveContext];
        } onError:^(NSString *error) {
            DLog(@"Problem loading notifications %@", error);
        }];
        
        NSError *error;
        BOOL success = [newMoc save:&error];
        //[newMoc release];
    });
    dispatch_release(request_queue);
    
}

- (void)loadPlacesPassively {
    
    dispatch_queue_t request_queue = dispatch_queue_create("com.ostrovok.Ostronaut.loadPlacesPassively", NULL);
    dispatch_async(request_queue, ^{
        AppDelegate *theDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        // Create a new managed object context
        // Set its persistent store coordinator
        NSManagedObjectContext *newMoc = [[NSManagedObjectContext alloc] init];
        [newMoc setPersistentStoreCoordinator:[theDelegate persistentStoreCoordinator]];
        
        // Register for context save changes notification
        NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
        [notify addObserver:self
                   selector:@selector(mergeChanges:)
                       name:NSManagedObjectContextDidSaveNotification
                     object:newMoc];
        
        [RestPlace searchByLat:[Location sharedLocation].latitude
                        andLon:[Location sharedLocation].longitude
                        onLoad:^(NSSet *places) {
                            for (RestPlace *restPlace in places) {
                                [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
                            }
                            [self saveContext];
                            
                        } onError:^(NSString *error) {
                            DLog(@"Problem searching places: %@", error);
                        }priority:NSOperationQueuePriorityVeryLow];
        
        NSError *error;
        BOOL success = [newMoc save:&error];
        //[newMoc release];
    });
    dispatch_release(request_queue);
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            [Flurry logError:@"FAILED_CONTEXT_SAVE" message:[error description] error:error];
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)mergeChanges:(NSNotification *)notification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];

}

@end
