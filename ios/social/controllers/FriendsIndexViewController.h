//
//  FriendsIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/16/12.
//
//

#import "CoreDataTableViewController.h"
#import "User.h"
@interface FriendsIndexViewController : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *user;

@end
