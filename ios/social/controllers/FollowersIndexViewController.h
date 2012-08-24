//
//  FollowersIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/23/12.
//
//

#import "CoreDataTableViewController.h"
#import "User+Rest.h"
@interface FollowersIndexViewController : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *user;
@end
