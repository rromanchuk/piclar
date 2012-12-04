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
#import "FacebookHelper.h"
#import "ThreadedUpdates.h"

@interface UsersListViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@end

@implementation UsersListViewController

@synthesize searchDisplayController;


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
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.title = self.list_title;
    
    [[ThreadedUpdates shared] loadSuggestedUsersForUser:self.currentUser.externalId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.fetchedResultsController = nil;
    self.searchFetchedResultsController = nil;
}

- (void)viewDidUnload
{
    [self set_tableView:nil];
    self.searchDisplayController = nil;
    [self setSearchBar:nil];
    [self setSearchDisplayController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"UserShow"]) {
        NewUserViewController *vc = (NewUserViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = (User *)sender;
        vc.currentUser = self.currentUser;
    } else if ([[segue identifier] isEqualToString:@"FindFriends"]) {
        UsersListViewController *vc = (UsersListViewController *) segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.list_title = NSLocalizedString(@"FIND_FRIENDS", nil);
        vc.usersList = [NSSet setWithArray:[User suggestedUsers:self.managedObjectContext]];
        vc.includeFindFriends = YES;
        vc.currentUser = self.currentUser;
        [Flurry logEvent:@"SCREEN_FIND_FRIENDS"];
    }
}

#pragma mark - Table view delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)theIndexPath
{
    static NSString *UserListCellIdentifier = @"UserListCell";
    static NSString *SearchCellIdentifier = @"SearchFriendsCell";
    if (theIndexPath.section == 0 && ![self.searchDisplayController isActive] && self.includeFindFriends) {
        SearchFriendsCell *cell = [self._tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        ALog(@"In search friends sections");
        if (cell == nil) {
            cell = [[SearchFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
        }
        if (theIndexPath.row == 1) {
            cell.searchTypeLabel.text = NSLocalizedString(@"ADDRESS_BOOK_SEARCH", @"Search for friends using address book");
            cell.descriptionLabel.text = NSLocalizedString(@"ADDRESS_BOOK_DESCRIPTION", @"Description on how it works");
            cell.searchTypePhoto.image = [UIImage imageNamed:@"Contacts-Icon.png"];
            
        } else if (theIndexPath.row == 0) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(didTapInviteFBFriends:)];
            [cell addGestureRecognizer:tap];
            cell.searchTypeLabel.text = NSLocalizedString(@"FACEBOOK", @"Search for friends using address book");
            cell.descriptionLabel.text =  NSLocalizedString(@"FACEBOOK_INVITE_FRIENDS", @"Description on how it works");
            cell.searchTypePhoto.image = [UIImage imageNamed:@"find-by-fb.png"];
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




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.searchDisplayController isActive]) {
        return 1;
    } else if (self.includeFindFriends) {
        return 2;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (![self.searchDisplayController isActive]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
        view.backgroundColor = RGBCOLOR(245, 245, 245);
        UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.tableView.frame.size.width, 23)];
        
        [view addSubview:sectionHeader];
        switch (section) {
            case 1:
                sectionHeader.text = self.list_title;
                break;
            default:
                break;
        }
        sectionHeader.backgroundColor = [UIColor clearColor];
        sectionHeader.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        sectionHeader.textColor = RGBCOLOR(92, 92, 92);
        return view;

        
    }
    return nil;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.searchDisplayController isActive]) {
        DLog(@"there are %d search objects", [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count]);
        return [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count];
    } else {
        if (self.includeFindFriends) {
            if (section == 0) {
                return 1; // 2;
            } else {
                return [[[self fetchedResultsControllerForTableView:tableView] fetchedObjects] count];
            }

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"didSelectRowAtIndexPath");
    if (self.includeFindFriends && indexPath.section == 0)
        return;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    User *user = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:newPath];
    [self performSegueWithIdentifier:@"UserShow" sender:user];
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
            if (theIndexPath.section != 0 || [self.searchDisplayController isActive]) {
                [self fetchedResultsController:controller configureCell:(LikerCell *)[tableView cellForRowAtIndexPath:theIndexPath] atIndexPath:theIndexPath];
            }
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
            [Flurry logEvent:@"FOLLOW_USER"];
        } onError:^(NSError *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    } else {
        [self.currentUser removeFollowingObject:c_user];
        [RestUser unfollowUser:c_user.externalId onLoad:^(RestUser *restUser) {
            [SVProgressHUD dismiss];
            [Flurry logEvent:@"UNFOLLOW_USER"];
        } onError:^(NSError *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
        
    }
    
    [self saveContext];
    [self.tableView reloadData];
}


- (IBAction)didTapFindFriends:(id)sender {
    [self performSegueWithIdentifier:@"FindFriends" sender:self];
}

- (IBAction)didTapInviteFBFriends:(id)sender {
    ALog(@"sending fb invite");
    [[FacebookHelper shared] login];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Check out this awesome app.",  @"message", nil];
    [[FacebookHelper shared].facebook dialog:@"apprequests" andParams:params andDelegate:nil];
}

#pragma mark CoreData methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}



@end
