//
//  UsersListViewController.h
//  Ostronaut
//
//  Created by Ivan Lazarev on 07.11.12.
//
//

#import "CoreDataTableViewController.h"
#import "User+Rest.h"
#import "NewUserViewController.h"
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
@property BOOL includeFindFriends;




@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

@property (strong, nonatomic) IBOutlet UITableView *_tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;




- (IBAction)followUnfollowUser:(id)sender;
- (IBAction)didTapInviteFBFriends:(id)sender;
@end

