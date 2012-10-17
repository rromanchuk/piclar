//
//  LikesShowViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import "CoreDataTableViewController.h"
#import "FeedItem.h"

@interface LikesShowViewController : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) User *currentUser;

@end
