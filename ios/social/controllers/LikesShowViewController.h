//
//  LikesShowViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import "CoreDataTableViewController.h"
#import "FeedItem.h"
#import "NewUserViewController.h"

@interface LikesShowViewController : CoreDataTableViewController <ProfileShowDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) User *currentUser;
- (IBAction)followUnfollowUser:(id)sender;
@end
