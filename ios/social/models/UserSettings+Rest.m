//
//  UserSettings+Rest.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "UserSettings+Rest.h"

@implementation UserSettings (Rest)


- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestNotification *restNotification = (RestNotification *) intermediateObject;
    
    self.externalId = [NSNumber numberWithInt:restNotification.externalId];
    self.type = restNotification.type;
    self.isRead = [NSNumber numberWithInt:restNotification.isRead];
    self.createdAt = restNotification.createdAt;
    self.notificationType = [NSNumber numberWithInt:restNotification.notificationType];
    self.sender = [User userWithRestUser:restNotification.sender inManagedObjectContext:self.managedObjectContext];
    self.placeTitle = restNotification.placeTitle;
}

@end
