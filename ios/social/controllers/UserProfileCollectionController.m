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

// Views
#import "UserProfileHeader.h"
#import "CheckinCollectionViewCell.h"
#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "Photo+Rest.h"
@interface UserProfileCollectionController ()

@end

@implementation UserProfileCollectionController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsDismissButton = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
	// Do any additional setup after loading the view.
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
    
    [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.checkin.firstPhoto.url];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}


- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UserProfileHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                         UICollectionElementKindSectionHeader withReuseIdentifier:@"UserProfileHeader" forIndexPath:indexPath];
    
    headerView.locationLabel.text = self.user.location;
    headerView.nameLabel.text = self.user.fullName;
    self.headerView = headerView;
    return self.headerView;
}

// 3
//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(50, 20, 50, 20);
//}

- (void)fetchResults {
       
    [RestUser loadFeedByIdentifier:self.user.externalId onLoad:^(NSSet *restFeedItems) {
        for (RestFeedItem *restFeedItem in restFeedItems) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
        }
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
