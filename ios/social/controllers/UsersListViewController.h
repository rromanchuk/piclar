//
//  UsersListViewController.h
//  Ostronaut
//
//  Created by Ivan Lazarev on 07.11.12.
//
//

#import "CoreDataTableViewController.h"
#import "User+Rest.h"
@interface UsersListViewController : BaseTableView <UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate> {
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
@property (strong, nonatomic) NSString *list_title;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSSet *usersList;

@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;
@property (strong, nonatomic) IBOutlet UITableView *_tableView;
- (IBAction)followUnfollowUser:(id)sender;

@end