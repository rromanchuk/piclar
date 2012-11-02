//
//  UserProfileCollectionController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "UserProfileCollectionController.h"

// Controllers
#import "UserSettingsController.h"
#import "FollowersIndexViewController.h"
#import "FollowingIndexViewController.h"
#import "CheckinViewController.h"

// Views
#import "UserProfileHeader.h"
#import "CheckinCollectionViewCell.h"
#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "Photo+Rest.h"
@interface UserProfileCollectionController ()

@end

@implementation UserProfileCollectionController {
    BOOL feedLayout;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsDismissButton = YES;
        feedLayout = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *settingsButtonItem = [UIBarButtonItem barItemWithImage:settingsButtonImage target:self action:@selector(didClickSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    if (self.user.isCurrentUser) {
        DLog(@"is current user");
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, settingsButtonItem, nil]];
    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.user.fullName;
    [self fetchResults];
}

- (void)viewDidUnload {
    [self setHeaderView:nil];
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
        FollowersIndexViewController *vc = (FollowersIndexViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
        vc.currentUser = self.currentUser;
    } else if ([[segue identifier] isEqualToString:@"UserFollowing"]) {
        FollowingIndexViewController *vc = (FollowingIndexViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
        vc.currentUser = self.currentUser;
        
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


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinCollectionCell";
    CheckinCollectionViewCell *cell = (CheckinCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIGestureRecognizer *tapPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressCheckinPhoto:)];
    [cell.checkinPhoto addGestureRecognizer:tapPhoto];
    cell.checkinPhoto.tag = indexPath.row;
    cell.checkinPhoto.userInteractionEnabled = YES;
    
    [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.url];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (feedLayout) {
        return CGSizeMake(310, 310);
    } else {
        return CGSizeMake(100, 100);
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
}


- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UserProfileHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:@"UserProfileHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    [self setupView];
    return self.headerView;
}

- (void)setupView {
    if (self.headerView) {
        self.headerView.locationLabel.text = self.user.location;
        self.headerView.nameLabel.text = self.user.fullName;
        [self.headerView.profilePhoto setProfileImageForUser:self.user];
        self.headerView.followButton.selected = [self.user.isFollowed boolValue];
        [self.headerView.followersButton setTitle:[NSString stringWithFormat:@"%d", [self.user.followers count]] forState:UIControlStateNormal];
        [self.headerView.followingButton setTitle:[NSString stringWithFormat:@"%d", [self.user.following count]] forState:UIControlStateNormal];
        
        [self.headerView.followButton setTitle:NSLocalizedString(@"FOLLOW", nil) forState:UIControlStateNormal];
        [self.headerView.followButton setTitle:NSLocalizedString(@"UNFOLLOW", nil) forState:UIControlStateSelected];
        
#warning not a true count..fix
        int checkins = [self.user.checkins count];
        if (checkins > 4) {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        } else if (checkins > 1) {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SECONDARY_PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        } else {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins,NSLocalizedString(@"PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        }

    }
}

// 3
//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}

- (void)fetchResults {
    RestUser *restUser = [[RestUser alloc] init];
    restUser.externalId = self.user.externalId.intValue;
    
    [restUser loadFollowing:^(NSSet *users) {
        [self.user removeFollowing:self.user.following];
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowingObject:_user];
        }
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"Error loading following %@", error);
        //
    }];
    
    [restUser loadFollowers:^(NSSet *users) {
        [self.user removeFollowers:self.user.followers];
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowersObject:_user];
        }
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"Error loading followers %@", error);
    }];

    [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
        for (RestFeedItem *restFeedItem in restFeedItems) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
        }
        [self setupView];
        [self.collectionView reloadData];

    } onError:^(NSString *error) {
        
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
            [self fetchResults];
            
        } onError:^(NSString *error) {
            self.headerView.followButton.enabled = YES;
            self.headerView.followButton.selected = !self.headerView.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.headerView.followButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
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
            [SVProgressHUD showErrorWithStatus:error];
        }];
    }
    //[self setupView];
}

- (IBAction)didPressCheckinPhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];

}

- (IBAction)didSwitchLayout:(id)sender {
    self.headerView.switchLayoutButton.selected = feedLayout = !self.headerView.switchLayoutButton.selected;
    [self.collectionView reloadData];
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
