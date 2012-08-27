//
//  FollowersIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/23/12.
//
//

#import "CoreDataTableViewController.h"
#import "User+Rest.h"
@interface FollowersIndexViewController : UITableViewController <UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate> {
    // required ivars for this example
    NSFetchedResultsController *fetchedResultsController_;
    NSFetchedResultsController *searchFetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;
@property (strong, nonatomic) IBOutlet UITableView *_tableView;

@end
