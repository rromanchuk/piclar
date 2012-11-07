//
//  FriendsIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/16/12.
//
//

#import "CoreDataTableViewController.h"
#import "User.h"
#import "NewUserViewController.h"
@interface FollowingIndexViewController : CoreDataTableViewController <ProfileShowDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) User *currentUser;

@end
