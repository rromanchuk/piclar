//
//  UserViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/6/12.
//
//

#import "UserViewController.h"
#import "UserSettingsController.h"
#import "UsersListViewController.h"
#import "CheckinViewController.h"
#import "ApplicatonNavigationController.h"

// Views
#import "CheckinCollectionViewCell.h"
#import "UserProfileHeader.h"
#import "CollectionNoResultsViewCell.h"
#import "LargeCheckinPhotoCollectionView.h"
#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "Photo.h"

#import "ThreadedUpdates.h"
#import "AppDelegate.h"
@implementation UserViewController
{
    BOOL feedLayout;
    BOOL noResults;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger items = [sectionInfo numberOfObjects];
    DLog(@"there are %d items", items);
    if (items == 0) {
        noResults = YES;
        items = 1;
    } else {
        noResults = NO;
    }
    return items;
}



- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        feedLayout = NO;
        needsBackButton = YES;
        noResults = YES;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.user.fullName;
    [self setupFetchedResultsController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchResults];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *settingsButtonItem = [UIBarButtonItem barItemWithImage:settingsButtonImage target:self action:@selector(didClickSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    if (self.user.isCurrentUser) {
        DLog(@"is current user");
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, settingsButtonItem, nil]];
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"UserSettings"]) {
        UserSettingsController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
    } else if ([[segue identifier] isEqualToString:@"UserFollowers"]) {
        UsersListViewController *vc = (UsersListViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.usersList = self.user.followers;
        vc.currentUser = self.currentUser;
        vc.list_title = NSLocalizedString(@"FOLLOWERS_TITLE", @"followers title");
        vc.includeFindFriends = NO;
        UIImage *findFriendsButtonImage = [UIImage imageNamed:@"find-friends.png"];
        UIBarButtonItem *findFriendsButton = [UIBarButtonItem barItemWithImage:findFriendsButtonImage target:vc action:@selector(didTapFindFriends:)];
        UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixed.width = 5;
        vc.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: fixed, findFriendsButton, nil];
        [Flurry logEvent:@"SCREEN_FOLLOWERS_LIST"];
    } else if ([[segue identifier] isEqualToString:@"UserFollowing"]) {
        UsersListViewController *vc = (UsersListViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.usersList = self.user.following;
        vc.currentUser = self.currentUser;
        vc.includeFindFriends = NO;
        vc.list_title = NSLocalizedString(@"FOLLOWING_TITLE", @"following title");
        UIImage *findFriendsButtonImage = [UIImage imageNamed:@"find-friends.png"];
        UIBarButtonItem *findFriendsButton = [UIBarButtonItem barItemWithImage:findFriendsButtonImage target:vc action:@selector(didTapFindFriends:)];
        UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixed.width = 5;
        vc.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: fixed, findFriendsButton, nil];
        [Flurry logEvent:@"SCREEN_FOLLOWING_LIST"];
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem*)sender;
        vc.currentUser = self.currentUser;
        vc.deletionDelegate = self;
    }
    
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"userProfileFeed" substitutionVariables:@{@"USER" : self.user}];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sharedAt" ascending:NO]];
    request.fetchLimit = 30;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - UICollectionViewDelegate
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"CheckinCollectionCell";
    static NSString *NoResultsCellIdentifier = @"CollectionNoResultsView";
    static NSString *LargePhotoCell = @"LargeCheckinPhotoCollectionView";

    if (noResults) {
        DLog(@"no results");
        CollectionNoResultsViewCell *cell =  (CollectionNoResultsViewCell *)[cv dequeueReusableCellWithReuseIdentifier:NoResultsCellIdentifier forIndexPath:indexPath];
        cell.noResultsLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstname, NSLocalizedString(@"USER_PROFILE_NO_CHECKINS", nil)];
        return cell;
        
    } else {
        int row = indexPath.row;
        int items = [[self.fetchedResultsController fetchedObjects] count];
        if (row < items && items > 0 ) {
            FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            // This is a hack for ios 5.1, for whatever reason the uiimageview is not listening to struts settings
            if (feedLayout) {
                LargeCheckinPhotoCollectionView *cell = (LargeCheckinPhotoCollectionView *)[cv dequeueReusableCellWithReuseIdentifier:LargePhotoCell forIndexPath:indexPath];
                [cell.checkinPhoto setFrame:CGRectMake(cell.checkinPhoto.frame.origin.x, cell.checkinPhoto.frame.origin.y, 310, 310)];
                [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.url];
                [cell setStars:[feedItem.checkin.userRating integerValue]];
                int numComments = [feedItem.comments count];
                int numLikes = [feedItem.liked count];
                if (numComments == 1) {
                    cell.commentsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SINGULAR_COMMENT", nil), numComments ];
                } else if (numComments < 5) {
                    cell.commentsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PLURAL_SECONDARY_COMMENTS", nil) , numComments];
                } else {
                    cell.commentsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PLURAL_COMMENTS", nil), numComments];
                }
                
                if (numLikes == 1) {
                    cell.likesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SINGULAR_LIKE", nil), numLikes];

                } else if (numLikes < 5) {
                    cell.likesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PLURAL_SECONDAY_LIKES", nil), numLikes];

                } else {
                    cell.likesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PLURAL_LIKES", nil), numLikes];

                }
                
                return cell;
            } else {
                CheckinCollectionViewCell *cell = (CheckinCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

                [cell.checkinPhoto setFrame:CGRectMake(cell.checkinPhoto.frame.origin.x, cell.checkinPhoto.frame.origin.y, 98, 98)];
                [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.thumbUrl];
                return cell;
            }
            
        }        
    }

}


- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (noResults) {
         return CGSizeMake(320, 320);
    } else {
        if (feedLayout) {
            return CGSizeMake(310, 350);
        } else {
            return CGSizeMake(98, 98);
        }
    }
    
}

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (noResults)
        return;
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
}

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.user.isCurrentUser) {
        return CGSizeMake(320, 220);
    } else {
        return CGSizeMake(320, 254);

    }
}

- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UserProfileHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                     PSTCollectionElementKindSectionHeader withReuseIdentifier:@"UserProfileHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    self.headerView.locationLabel.text = self.user.location;
    self.headerView.nameLabel.text = self.user.fullName;
    [self.headerView.profilePhoto setProfileImageForUser:self.user];
    self.headerView.followButton.selected = [self.user.isFollowed boolValue];
    [self.headerView.followersButton setTitle:[NSString stringWithFormat:@"%d", [self.user.followers count]] forState:UIControlStateNormal];
    [self.headerView.followingButton setTitle:[NSString stringWithFormat:@"%d", [self.user.following count]] forState:UIControlStateNormal];
    
    [self.headerView.followButton setTitle:NSLocalizedString(@"FOLLOW", nil) forState:UIControlStateNormal];
    [self.headerView.followButton setTitle:NSLocalizedString(@"UNFOLLOW", nil) forState:UIControlStateSelected];
    
    [self.headerView.switchLayoutButton addTarget:self action:@selector(didSwitchLayout:) forControlEvents:UIControlEventTouchUpInside];
    self.headerView.switchLayoutButton.selected = feedLayout;
    
    if (self.user.isCurrentUser) {
        self.headerView.followButton.hidden = YES;
        [self.headerView.switchLayoutButton setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.switchLayoutButton.frame.size.width, self.headerView.switchLayoutButton.frame.size.height)];
        [self.headerView setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.switchLayoutButton.frame.origin.y + self.headerView.switchLayoutButton.frame.size.height + 5)];
        
    } else {
        self.headerView.followButton.hidden = NO;
        [self.headerView.switchLayoutButton setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.followButton.frame.origin.y + self.headerView.followButton.frame.size.height + 5, self.headerView.switchLayoutButton.frame.size.width, self.headerView.switchLayoutButton.frame.size.height)];
        [self.headerView setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.switchLayoutButton.frame.origin.y + self.headerView.switchLayoutButton.frame.size.height + 10)];
    }
#warning not a true count..fix
    int checkins = [self.user.checkins count];
    if (checkins > 4) {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    } else if (checkins > 1) {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SECONDARY_PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    } else {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SINGLE_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    }

    return self.headerView;
}


- (void)setupView {
    [self.collectionView reloadData];
}


// Theoretically, this should really only need to be called once in the application's lfetime
// ^ It's not true. We need load person feed information for every person we open
- (void)fetchFeed {
        
    NSManagedObjectContext *loadFeedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    loadFeedContext.parentContext = self.managedObjectContext;

    
    [loadFeedContext performBlock:^{
        [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
            for (RestFeedItem *restFeedItem in restFeedItems) {
                [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
            }
            // push to parent
            NSError *error;
            if (![loadFeedContext save:&error])
            {
                // handle error
                ALog(@"error %@", error);
            }
            
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"error %@", error);
                } else {
                    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [sharedAppDelegate writeToDisk];
                    self.pauseUpdates = NO;
                    [self.collectionView reloadData];
                }
            }];
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading feed %@", error);
            self.pauseUpdates = NO;
        }];
        
    }];

}

- (void)fetchResults {
    self.pauseUpdates = YES;
    [self fetchFollowingFollowers];
    [self fetchFeed];
}

- (void)fetchFollowingFollowers {

    
    NSManagedObjectContext *loadFollowingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    loadFollowingContext.parentContext = self.managedObjectContext;
    
    [loadFollowingContext performBlock:^{
       [RestUser loadFollowingInfo:self.user.externalId onLoad:^(RestUser *restUser) {
           [User findOrCreateUserWithRestUser:restUser inManagedObjectContext:loadFollowingContext];

           // save parent to disk asynchronously
           [self.managedObjectContext performBlock:^{
               NSError *error;
               if (![self.managedObjectContext save:&error])
               {
                   // handle error
                   ALog(@"error %@", error);
               } else {
                   AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                   [sharedAppDelegate writeToDisk];
               }
               [self.collectionView reloadData];
           }];
           
           
       } onError:^(NSError *error) {
           ALog(@"Error loading following: %@", error);
       }];
        
    }];
}


#pragma mark - User events


- (IBAction)didFollowUnfollowUser:(id)sender {
    self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
    self.headerView.followButton.enabled = NO;
    if (self.headerView.followButton.selected) {
        self.headerView.followButton.selected = !self.headerView.followButton.selected;
        //[self.currentUser removeFollowingObject:self.user];
        [self.user removeFollowersObject:self.currentUser];
        [self.collectionView reloadData];
        // ios 6.0 bug
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
        [RestUser unfollowUser:self.user.externalId onLoad:^(RestUser *restUser) {
            DLog(@"success unfollow user");
            self.headerView.followButton.enabled = YES;
            [Flurry logEvent:@"UNFOLLOW_USER"];
            [self fetchFollowingFollowers];
        } onError:^(NSError *error) {
            self.headerView.followButton.enabled = YES;
            self.headerView.followButton.selected = !self.headerView.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self saveContext];
        }];
    } else {
        self.headerView.followButton.selected = !self.headerView.followButton.selected;
        //[self.currentUser addFollowingObject:self.user];
        [self.user addFollowersObject:self.currentUser];
        [self.collectionView reloadData];
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
        [RestUser followUser:self.user.externalId onLoad:^(RestUser *restUser) {
            self.headerView.followButton.enabled = YES;
            [Flurry logEvent:@"FOLLOW_USER"];
            [self fetchFollowingFollowers];
            DLog(@"sucess follow user");
        } onError:^(NSError *error) {
            self.headerView.followButton.enabled = YES;
            self.headerView.followButton.selected = !self.headerView.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
            [self saveContext];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    }
    [self saveContext];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            [Flurry logError:@"FAILED_CONTEXT_SAVE" message:[error description] error:error];
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (IBAction)didPressCheckinPhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
    
}

- (IBAction)didSwitchLayout:(id)sender {
    feedLayout = !((UIButton *)sender).selected;
    [self setupView];
}

- (IBAction)didTapFollowers:(id)sender {
    [self performSegueWithIdentifier:@"UserFollowers" sender:self];
}

- (IBAction)didTapFollowing:(id)sender {
    [self performSegueWithIdentifier:@"UserFollowing" sender:self];
}

- (IBAction)didClickSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserSettings" sender:self];
}

# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - DeletionHandlerDelegate
- (void)deleteFeedItem: (FeedItem *)feedItem {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_FEED", @"Loading screen for deleting user's comment") maskType:SVProgressHUDMaskTypeGradient];
    [RestFeedItem deleteFeedItem:feedItem.externalId onLoad:^(RestFeedItem *restFeedItem) {
        [feedItem deactivate];
        [self saveContext];
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
        [((ApplicatonNavigationController *)self.navigationController) back:self];
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];

    
}

@end
