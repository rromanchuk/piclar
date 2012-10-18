//
//  UserProfileViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/15/12.
//
//

// Controllers
#import "UserSettingsController.h"
#import "UserProfileViewController.h"
#import "FollowersIndexViewController.h"

// CoreData
#import "Checkin+Rest.h"
#import "Photo.h"
@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

#pragma mark - ViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.checkins = [self.user.checkins allObjects];
    
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *settingsButtonItem = [UIBarButtonItem barItemWithImage:settingsButtonImage target:self action:@selector(didClickSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, dismissButtonItem, nil]];
    if (self.user.isCurrentUser) {
        DLog(@"is current user");
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, settingsButtonItem, nil]];
    }

    self.carouselView.type = iCarouselTypeWheel;
    
    self.carouselView.backgroundColor = [UIColor clearColor];
    
    [self setupView];
    [self.profilePhoto setProfileImageForUser:self.user];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.locationLabel.text = self.user.location;
    self.nameLabel.text = self.user.fullName;
    self.title = self.user.fullName;
    self.numPostcardsLabel.text = [NSString stringWithFormat:@"%d %@", [self.checkins count], NSLocalizedString(@"POSTCARDS", nil)];
    self.followButton.selected = [self.user.isFollowed boolValue];
    [self fetchResults];
    [self.user updateFromServer];
}


- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setNumPostcardsLabel:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setCarouselView:nil];
    [self setFollowButton:nil];
    [super viewDidUnload];
}

- (void)setupView {
    [self.followersButton setTitle:[NSString stringWithFormat:@"%d", [self.user.followers count]] forState:UIControlStateNormal];
    [self.followingButton setTitle:[NSString stringWithFormat:@"%d", [self.user.following count]] forState:UIControlStateNormal];
    self.followButton.selected = [self.user.isFollowed boolValue];
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
   } else if ([[segue identifier] isEqualToString:@"UserFollowing"]) {
       FollowersIndexViewController *vc = (FollowersIndexViewController *)segue.destinationViewController;
       vc.managedObjectContext = self.managedObjectContext;
       vc.user = self.user;
   }

}


- (IBAction)dismissModal:(id)sender {
    [self.delegate didDismissProfile];
}

- (IBAction)didClickSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserSettings" sender:self];
}


#pragma mark - iCarousel delegate methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [self.user.checkins count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        
        view.tag = 1;
    } else {
        
    }
    Checkin *checkin = [self.checkins objectAtIndex:index];
    NSURL *request = [NSURL URLWithString:[checkin firstPhoto].url];
    [((UIImageView *)view) setImageWithURL:request];
    return view;
}

#pragma mark - CoreData Syncing

- (void)updateUser {

}

- (void)fetchResults {
    [RestUser loadFollowing:^(NSSet *users) {
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowingObject:_user];
        }
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"Error loading following %@", error);
        //
    }];
    
    [RestUser loadFollowers:^(NSSet *users) {
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowersObject:_user];
        }
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"Error loading followers %@", error);
    }];
    
}


# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - User events


- (IBAction)didFollowUnfollowUser:(id)sender {
    if (self.followButton.selected) {
        self.user.isFollowed = [NSNumber numberWithBool:!self.followingButton.selected];
        self.followingButton.selected = !self.followingButton.selected;
        [RestUser unfollowUser:self.user.externalId onLoad:^(RestUser *restUser) {
            DLog(@"success unfollow user");
        } onError:^(NSString *error) {
            self.followingButton.selected = !self.followingButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.followingButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        self.followingButton.selected = !self.followingButton.selected;
        self.user.isFollowed = [NSNumber numberWithBool:!self.followingButton.selected];
        [RestUser followUser:self.user.externalId onLoad:^(RestUser *restUser) {
            DLog(@"sucess follow user");
        } onError:^(NSString *error) {
            self.followingButton.selected = !self.followingButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.followingButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
        }];

    }
}
@end
