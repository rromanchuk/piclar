//
//  FollowersIndexViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/23/12.
//
//

#import "FollowersIndexViewController.h"
#import "FollowFriendCell.h"
#import "SearchFriendsCell.h"
@interface FollowersIndexViewController ()

@end

@implementation FollowersIndexViewController
@synthesize managedObjectContext;
@synthesize user = _user;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"self IN %@", self.user.followers];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastname" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"SearchFriendsCell";
        SearchFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (indexPath.row == 0) {
            cell.searchTypeLabel.text = NSLocalizedString(@"ADDRESS_BOOK_SEARCH", @"Search for friends using address book");
            cell.descriptionLabel.text = NSLocalizedString(@"ADDRESS_BOOK_DESCRIPTION", @"Description on how it works");
            [cell.searchTypePhoto setProfileImage:[UIImage imageNamed:@"address-book-icon.png"]];
        } else if (indexPath.row == 1) {
            cell.searchTypeLabel.text = NSLocalizedString(@"VK_SEARCH", @"Search for friends using address book");
            cell.descriptionLabel.text =  NSLocalizedString(@"VK_DESCRIPTION", @"Description on how it works");
            [cell.searchTypePhoto setProfileImage:[UIImage imageNamed:@"vk-icon.png"]];
        }
        return cell;
        
    } else if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"FollowFriendCell";
        FollowFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.fullnameLabel.text = user.normalFullName;
        [cell.profilePhotoView setProfileImageWithUrl:user.remoteProfilePhotoUrl];
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else {
        return [[self.fetchedResultsController fetchedObjects] count];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
