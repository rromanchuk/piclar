//
//  Notification+Rest.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "Notification.h"
#import "RestNotification.h"

@interface Notification (Rest)

+ (Notification *)notificatonWithRestNotification:(RestNotification *)restNotification
    inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

@end
