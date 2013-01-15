//
//  Notification+Rest.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "Notification+Rest.h"
#import "User+Rest.h"
#import "FeedItem+Rest.h"

@implementation Notification (Rest)


+ (Notification *)notificatonWithRestNotification:(RestNotification *)restNotification
                           inManagedObjectContext:(NSManagedObjectContext *)context {
    Notification *notification;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restNotification.externalId]];
    
    NSError *error = nil;
    NSArray *notifications = [context executeFetchRequest:request error:&error];
    
    if (!notifications || ([notifications count] > 1)) {
        // handle error
    } else if (![notifications count]) {
        notification = [NSEntityDescription insertNewObjectForEntityForName:@"Notification"
                                             inManagedObjectContext:context];
        
        [notification setManagedObjectWithIntermediateObject:restNotification];
        
    } else {
        notification = [notifications lastObject];
        [notification setManagedObjectWithIntermediateObject:restNotification];

    }
    
    return notification;

}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestNotification *restNotification = (RestNotification *) intermediateObject;
    self.externalId = [NSNumber numberWithInt:restNotification.externalId];
    self.type = restNotification.type;
    self.isRead = [NSNumber numberWithInt:restNotification.isRead];
    self.createdAt = restNotification.createdAt;
    self.notificationType = [NSNumber numberWithInt:restNotification.notificationType];
    self.sender = [User userWithRestUser:restNotification.sender inManagedObjectContext:self.managedObjectContext];
    self.placeTitle = restNotification.placeTitle;
    self.feedItemId = [NSNumber numberWithInteger:restNotification.feedItemId];
    self.isActive = [NSNumber numberWithBool:restNotification.isActive];
    //self.feedItem = [FeedItem feedItemWithRestFeedItem:restNotification.feedItem inManagedObjectContext:self.managedObjectContext];
}


+ (void)markAllAsRead:(void (^)(bool status))onLoad
              onError:(void (^)(NSError *error))onError
              forUser:(User *)user
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", user];
    NSError *error = nil;
    NSArray *notifications = [context executeFetchRequest:request error:&error];
    for (Notification *notification in notifications) {
        notification.isRead = [NSNumber numberWithBool:YES];
    }
    [RestNotification markAllAsRead:onLoad onError:onError];
}

- (void)updateNotificationWithRestNotification:(RestNotification *)restNotification {
    [self setManagedObjectWithIntermediateObject:restNotification];
}

@end
