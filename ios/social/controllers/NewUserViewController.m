//
//  NewUserViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/6/12.
//
//

#import "NewUserViewController.h"
#import "UserSettingsController.h"
#import "UsersListViewController.h"
#import "CheckinViewController.h"

#import "CheckinCollectionViewCell.h"
#import "UserProfileHeader.h"

#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "Photo.h"

#import "ThreadedUpdates.h"
#import "AppDelegate.h"
@implementation NewUserViewController
{
    BOOL feedLayout;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        feedLayout = NO;
        needsBackButton = YES;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated]; 
    self.title = self.user.normalFullName;
    [self setupFetchedResultsController];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharedAppDelegate writeToDisk];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem*)sender;
        vc.currentUser = self.currentUser;
    }
    
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sharedAt" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


#pragma mark - UICollectionViewDelegate
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"CheckinCollectionCell";
    CheckinCollectionViewCell *cell = (CheckinCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    int row = indexPath.row;
    int items = [[self.fetchedResultsController fetchedObjects] count];
    if (row < items && items > 0 ) {
        FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        // This is a hack for ios 5.1, for whatever reason the uiimageview is not listening to struts settings 
        if (feedLayout) {
            [cell.checkinPhoto setFrame:CGRectMake(cell.checkinPhoto.frame.origin.x, cell.checkinPhoto.frame.origin.y, 310, 310)];
        }
        [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.url];
    }
    
    
    return cell;
}


- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (feedLayout) {
        return CGSizeMake(320, 320);
    } else {
        return CGSizeMake(100, 100);
    }
}

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
}


- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UserProfileHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                     PSTCollectionElementKindSectionHeader withReuseIdentifier:@"UserProfileHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    ALog(@"in returning supplementary view");
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
    } else {
        self.headerView.followButton.hidden = NO;
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
    ALog(@"In setupview %@", self.collectionView);
    [self.collectionView reloadData];
}


// Theoretically, this should really only need to be called once in the application's lfetime
- (void)fetchFeed {
    [self.managedObjectContext performBlock:^{
        [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
            for (RestFeedItem *restFeedItem in restFeedItems) {
                [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
            }
            // push to parent
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
            
        } onError:^(NSString *error) {
            ALog(@"Problem loading feed %@", error);
        }];
        
    }];

}

- (void)fetchResults {
    [self fetchFollowingFollowers];
    [self fetchFeed];
}

- (void)fetchFollowingFollowers {
//    [[ThreadedUpdates shared] loadFollowersPassively:self.user.externalId];
//    [[ThreadedUpdates shared] loadFollowingPassively:self.user.externalId];
//    [[ThreadedUpdates shared] loadFeedPassively:self.user.externalId];

    NSManagedObjectContext *moc = self.managedObjectContext;
    User *user = self.user;
    [moc performBlock:^{
       [RestUser loadFollowing:self.user.externalId onLoad:^(NSSet *users) {
           [user removeFollowing:user.following];
           NSMutableSet *following = [[NSMutableSet alloc] init];
           for (RestUser *friend_restUser in users) {
               User *user_ = [User userWithRestUser:friend_restUser inManagedObjectContext:self.managedObjectContext];
               [following addObject:user_];
           }
           [self.user addFollowing:following];
           // push to parent
           NSError *error;
           if (![moc save:&error])
           {
               ALog(@"Error saving temporary context %@", error);
           }
           
           
       } onError:^(NSString *error) {
           ALog(@"Error loading following: %@", error);
       }];
        
    }];
    
    
    [moc performBlock:^{
        [RestUser loadFollowers:user.externalId onLoad:^(NSSet *users) {
            [user removeFollowers:user.followers];
            NSMutableSet *followers = [[NSMutableSet alloc] init];
            for (RestUser *friend_restUser in users) {
                User *user_ = [User userWithRestUser:friend_restUser inManagedObjectContext:moc];
                [followers addObject:user_];
            }
            [user addFollowers:followers];
            // push to parent
            NSError *error;
            if (![moc save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
        } onError:^(NSString *error) {
            ALog(@"Error loading followers %@", error);
        }];
    }];
    
    
  
    [moc performBlock:^{
        [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
            for (RestFeedItem *restFeedItem in restFeedItems) {
                [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:moc];
            }
            // push to parent
            NSError *error;
            if (![moc save:&error])
            {
                ALog(@"Error saving temporary context %@", error);
            }
            //[self.collectionView reloadData];
            
        } onError:^(NSString *error) {
            ALog(@"Problem loading feed %@", error);
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
        [RestUser unfollowUser:self.user.externalId onLoad:^(RestUser *restUser) {
            DLog(@"success unfollow user");
            self.headerView.followButton.enabled = YES;
            [self fetchFollowingFollowers];
            
        } onError:^(NSString *error) {
            self.headerView.followButton.enabled = YES;
            self.headerView.followButton.selected = !self.headerView.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
            [self saveContext];
        }];
    } else {
        self.headerView.followButton.selected = !self.headerView.followButton.selected;
        //[self.currentUser addFollowingObject:self.user];
        [self.user addFollowersObject:self.currentUser];
        
        [RestUser followUser:self.user.externalId onLoad:^(RestUser *restUser) {
            self.headerView.followButton.enabled = YES;
            [self fetchFollowingFollowers];
            DLog(@"sucess follow user");
        } onError:^(NSString *error) {
            self.headerView.followButton.enabled = YES;
            self.headerView.followButton.selected = !self.headerView.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
            [self saveContext];
            [SVProgressHUD showErrorWithStatus:error];
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
    ALog(@"did switch layout");
    feedLayout = !((UIButton *)sender).selected;
    if (feedLayout) {
        ALog(@"FEED LAYOUT");
    } else {
        ALog(@"GRID LAYOUT");
    }
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

@end
