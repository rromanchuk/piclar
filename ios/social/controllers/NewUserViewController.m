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
@implementation NewUserViewController
{
    BOOL feedLayout;
}



- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        feedLayout = NO;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
 
    self.title = self.user.normalFullName;
    [self setupView];
    [self fetchResults];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.fetchedResultsController = nil;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupView) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: dismissButtonItem, nil]];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
    
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
    } else if ([[segue identifier] isEqualToString:@"UserFollowing"]) {
        UsersListViewController *vc = (UsersListViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.usersList = self.user.following;
        vc.currentUser = self.currentUser;
        vc.list_title = NSLocalizedString(@"FOLLOWING_TITLE", @"following title");
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem*)sender;
        vc.currentUser = self.currentUser;
    }
    
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
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
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.url];
    return cell;
}


- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (feedLayout) {
        return CGSizeMake(310, 310);
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
    ALog(@"In setupview");
    [self.collectionView reloadData];
}


- (void)fetchResults {
    [RestUser loadByIdentifier:self.user.externalId onLoad:^(RestUser *restUser) {
        self.user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
        
        [RestUser loadFollowing:[NSNumber numberWithInteger:restUser.externalId] onLoad:^(NSSet *users) {
            [self.user removeFollowing:self.user.following];
            NSMutableSet *following = [[NSMutableSet alloc] init];
            for (RestUser *friend_restUser in users) {
                User *_user = [User userWithRestUser:friend_restUser inManagedObjectContext:self.managedObjectContext];
                [following addObject:_user];
            }
            [self.user addFollowing:following];
            [self saveContext];
        } onError:^(NSString *error) {
            DLog(@"Error loading following %@", error);
        }];
        
        
        [RestUser loadFollowers:[NSNumber numberWithInteger:restUser.externalId] onLoad:^(NSSet *users) {
            [self.user removeFollowers:self.user.followers];
            NSMutableSet *followers = [[NSMutableSet alloc] init];
            for (RestUser *friend_restUser in users) {
                User *_user = [User userWithRestUser:friend_restUser inManagedObjectContext:self.managedObjectContext];
                [followers addObject:_user];
            }
            [self.user addFollowers:followers];
            [self saveContext];

        } onError:^(NSString *error) {
            DLog(@"Error loading followers %@", error);

        }];
        
    } onError:^(NSString *error) {
        
    }];
    
    [[ThreadedUpdates shared] loadFeedPassively:self.user.externalId];
    
//    [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
//        for (RestFeedItem *restFeedItem in restFeedItems) {
//            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
//        }
//        [self saveContext];
//        [self.collectionView reloadData];
//        
//    } onError:^(NSString *error) {
//        
//    }];

    
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
            [self fetchResults];
            
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
            [self fetchResults];
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


- (IBAction)dismissModal:(id)sender {
    [self.delegate didDismissProfile];
}

- (IBAction)didClickSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserSettings" sender:self];
}

# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

@end
