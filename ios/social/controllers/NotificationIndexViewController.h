//
//  NotificationIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "CoreDataTableViewController.h"
#import "User.h"
#import "UserProfileViewController.h"

@interface NotificationIndexViewController : CoreDataTableViewController <ProfileShowDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;

@end
