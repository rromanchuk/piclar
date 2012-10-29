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
#import "FollowingIndexViewController.h"
// CoreData
#import "Checkin+Rest.h"
#import "Photo.h"
@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsDismissButton = YES;
    }
    return self;
}

#pragma mark - ViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.checkins = [self.user.checkins allObjects];
    
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *settingsButtonItem = [UIBarButtonItem barItemWithImage:settingsButtonImage target:self action:@selector(didClickSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    if (self.user.isCurrentUser) {
        DLog(@"is current user");
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, settingsButtonItem, nil]];
    }

    self.carouselView.type = iCarouselTypeWheel;
    
    self.carouselView.backgroundColor = [UIColor clearColor];
    [self.profilePhoto setProfileImageForUser:self.user];
    [self setupView];
    [self fetchResults];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.locationLabel.text = self.user.location;
    self.nameLabel.text = self.user.fullName;
    self.title = self.user.fullName;
    self.numPostcardsLabel.text = [NSString stringWithFormat:@"%d %@", [self.checkins count], NSLocalizedString(@"POSTCARDS", nil)];
    [self.user updateFromServer];
    if (self.currentUser.externalId.intValue == self.user.externalId.intValue) {
        self.followButton.hidden = YES;
        CGFloat PADDING = self.followersButton.frame.size.width * 0.6;
        self.followersButton.center = CGPointMake(self.view.frame.size.width /2 - PADDING , self.followersButton.center.y);
        self.followingButton.center = CGPointMake(self.view.frame.size.width /2 + PADDING , self.followingButton.center.y);
    } else {
        self.followButton.selected = [self.user.isFollowed boolValue];
    }
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setNumPostcardsLabel:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
//    [self setCaroduselView:nil];
    [self setFollowButton:nil];
    [super viewDidUnload];
}

- (void)setupView {
    DLog(@"FOLLOWERS %@",[self.user.followers allObjects]);
    DLog(@"FOLLOWING %@",[self.user.following allObjects]);
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
       vc.currentUser = self.currentUser;
   } else if ([[segue identifier] isEqualToString:@"UserFollowing"]) {
       FollowingIndexViewController *vc = (FollowingIndexViewController *)segue.destinationViewController;
       vc.managedObjectContext = self.managedObjectContext;
       vc.user = self.user;
       vc.currentUser = self.currentUser;

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
    
}


# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - User events


- (IBAction)didFollowUnfollowUser:(id)sender {
    self.user.isFollowed = [NSNumber numberWithBool:!self.followButton.selected];
    self.followButton.enabled = NO;
    if (self.followButton.selected) {
        self.followButton.selected = !self.followButton.selected;
        //[self.currentUser removeFollowingObject:self.user];
        [self.user removeFollowersObject:self.currentUser];
        [RestUser unfollowUser:self.user.externalId onLoad:^(RestUser *restUser) {
            DLog(@"success unfollow user");
            self.followButton.enabled = YES;
            [self fetchResults];

        } onError:^(NSString *error) {
            self.followButton.enabled = YES;
            self.followButton.selected = !self.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.followButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        self.followButton.selected = !self.followButton.selected;
        //[self.currentUser addFollowingObject:self.user];
        [self.user addFollowersObject:self.currentUser];
        
        [RestUser followUser:self.user.externalId onLoad:^(RestUser *restUser) {
            self.followButton.enabled = YES;
            [self fetchResults];
            DLog(@"sucess follow user");
        } onError:^(NSString *error) {
            self.followButton.enabled = YES;
            self.followButton.selected = !self.followButton.selected;
            self.user.isFollowed = [NSNumber numberWithBool:!self.followButton.selected];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    }
    [self setupView];
}
@end
