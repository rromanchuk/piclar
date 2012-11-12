//
//  NotificationHandler.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/16/12.
//
//

#import <Foundation/Foundation.h>
#import "UAPush.h"
#import "User.h"
@interface NotificationHandler : NSObject <UAPushNotificationDelegate>
@property (strong, nonatomic) User *currentUser;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

