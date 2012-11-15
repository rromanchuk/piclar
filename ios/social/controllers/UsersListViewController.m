//
//  UsersListViewController.m
//  Ostronaut
//
//  Created by Ivan Lazarev on 07.11.12.
//
//

#import "UsersListViewController.h"
#import "SearchFriendsCell.h"
#import "LikerCell.h"

@interface UsersListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@end

@implementation UsersListViewController
@synthesize _tableView;
@synthesize managedObjectContext;
@synthesize list_title = _list_title;
@synthesize usersList = _usersList;
@synthesize currentUser = _currentUser;
@synthesize savedSearchTerm;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

#pragma mark - ViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.title = self.list_title;
}
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self set_tableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        NewUserViewController *vc = (NewUserViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        
        User *user;
        ALog(@"selected index path %@", self._tableView.indexPathForSelectedRow);
        if (![self.searchDisplayController isActive]) {
            NSIndexPath *test = [NSIndexPath indexPathForRow:self._tableView.indexPathForSelectedRow.row inSection:0];
            user = [self.fetchedResultsController objectAtIndexPath:test];
        } else {
            user = [self.searchFetchedResultsController objectAtIndexPath:self._tableView.indexPathForSelectedRow];

        }
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.user = user;
        vc.currentUser = self.currentUser;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    static NSString *UserListCellIdentifier = @"UserListCell";
    static NSString *SearchCellIdentifier = @"SearchFriendsCell";
    
    if (theIndexPath.section == 0 && ![self.searchDisplayController isActive]) {
        SearchFriendsCell *cell = [self._tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        if (cell == nil) {
            cell = [[SearchFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
        }
        if (theIndexPath.row == 0) {
            cell.searchTypeLabel.text = NSLocalizedString(@"ADDRESS_BOOK_SEARCH", @"Search for friends using address book");
            cell.descriptionLabel.text = NSLocalizedString(@"ADDRESS_BOOK_DESCRIPTION", @"Description on how it works");
            [cell.searchTypePhoto setProfileImage:[UIImage imageNamed:@"Contacts-Icon.png"]];
        } else if (theIndexPath.row == 1) {
            cell.searchTypeLabel.text = NSLocalizedString(@"VK_SEARCH", @"Search for friends using address book");
            cell.descriptionLabel.text =  NSLocalizedString(@"VK_DESCRIPTION", @"Description on how it works");
            [cell.searchTypePhoto setProfileImage:[UIImage imageNamed:@"Vkontakte-Icon.png"]];
        }
        return cell;
        
    } else if (theIndexPath.section == 1) {
        LikerCell *cell = [self._tableView dequeueReusableCellWithIdentifier:UserListCellIdentifier];
        if (cell == nil) {
            cell = [[LikerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserListCellIdentifier];
        }
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:theIndexPath.row inSection:0];
        [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:newIndexPath];
        return cell;
        
    } else {
        
        DLog(@"Returning a cell for search");
        
        LikerCell *cell = [self._tableView dequeueReusableCellWithIdentifier:UserListCellIdentifier];
        if (cell == nil) {
            cell = [[LikerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UserListCellIdentifier];
        }
        [self fetchedResultsController:[self fetchedResultsControllerForTableView:theTableView] configureCell:cell atIndexPath:theIndexPath];
        return cell;
    }
}


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(LikerCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
{
    // Configure the cell...
    DLog(@"There are %d objects", [[fetchedResultsController fetchedObjects] count]);
    User *user = [fetchedResultsController objectAtIndexPath:theIndexPath];
    theCell.followButton.hidden = user.isCurrentUser;
    theCell.nameLabel.text = user.normalFullName;
    theCell.locationLabel.text = user.location;
    [theCell.profilePhoto setProfileImageForUser:user];
    theCell.followButton.selected = [user.isFollowed boolValue];
    theCell.followButton.tag = theIndexPath.row;
    [theCell.followButton setTitle:NSLocalizedString(@"FOLLOW", @"Follow button") forState:UIControlStateNormal];
    [theCell.followButton setTitle:NSLocalizedString(@"UNFOLLOW", @"Follow button") forState:UIControlStateSelected];
    
}


#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.searchDisplayController isActive]) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchDisplayController isActive]) {
        DLog(@"there are %d search objects", [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count]);
        return [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count];
    } else {
        if (section == 0) {
            return 0; // 2;
        } else {
            return [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}


#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    //self.searchFetchedResultsController.delegate = nil;
    //self.searchFetchedResultsController = nil;
    searchFetchedResultsController_.delegate = nil;
    searchFetchedResultsController_ = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    //self.searchFetchedResultsController.delegate = nil;
    //self.searchFetchedResultsController = nil;
    searchFetchedResultsController_.delegate = nil;
    searchFetchedResultsController_ = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    DLog(@"shouldReloadTableForSearchString: %@", searchString);
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)theIndexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:(LikerCell *)[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:theIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
    [tableView endUpdates];
}


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastname" ascending:YES]];
    NSPredicate *filterPredicate = [NSPredicate
                                    predicateWithFormat:@"self IN %@", self.usersList];
    
    DLog(@"FETCH FOR USER: %i", [self.usersList count])
    
    /*x§
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length)
    {
        DLog(@"New NFRC with search string: %@", searchString);
        // your search predicate(s) are added to this array
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"firstname CONTAINS[cd] %@ OR lastname CONTAINS[cd] %@", searchString, searchString]];
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ != nil)
    {
        return fetchedResultsController_;
    }
    fetchedResultsController_ = [self newFetchedResultsControllerWithSearch:nil];
    return fetchedResultsController_;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (searchFetchedResultsController_ != nil)
    {
        return searchFetchedResultsController_;
    }
    searchFetchedResultsController_ = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return searchFetchedResultsController_;
}

#pragma mark - User actions

- (IBAction)followUnfollowUser:(id)sender {
    UIButton *followButton = (UIButton *)sender;
    int row = followButton.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    User *c_user;
    if (![self.searchDisplayController isActive]) {
        c_user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        DLog(@"coming from search results");
        c_user = [self.searchFetchedResultsController objectAtIndexPath:indexPath];
    }
    
    DLog(@"got user %@", c_user);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
    c_user.isFollowed = [NSNumber numberWithBool:![c_user.isFollowed boolValue]];
    followButton.selected = !followButton.selected;
    if (followButton.selected) {
        [self.currentUser addFollowingObject:c_user];
        
        [RestUser followUser:c_user.externalId onLoad:^(RestUser *restUser) {
            [SVProgressHUD dismiss];
        } onError:^(NSString *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        [self.currentUser removeFollowingObject:c_user];
        [RestUser unfollowUser:c_user.externalId onLoad:^(RestUser *restUser) {
            [SVProgressHUD dismiss];
        } onError:^(NSString *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error];
        }];
        
    }
    
    [self saveContext];
    [self.tableView reloadData];
}

#pragma mark CoreData methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

@end
