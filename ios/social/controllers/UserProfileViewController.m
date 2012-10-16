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
    //[self.userFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%u", [self.user.followers count]]];
    //[self.checkinsButton setTitle:[NSString stringWithFormat:@"%u", [self.user.checkinsCount intValue]] forState:UIControlStateNormal];
    [self.profilePhoto setProfileImageForUser:self.user];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.locationLabel.text = self.user.location;
    self.nameLabel.text = self.user.fullName;
    self.title = self.user.fullName;
    self.numPostcardsLabel.text = [NSString stringWithFormat:@"%d %@", [self.checkins count], NSLocalizedString(@"PHOTOGRAPHS", nil)];
}


- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setNumPostcardsLabel:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setCarouselView:nil];
    [super viewDidUnload];
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"UserSettings"]) {
        UserSettingsController *vc = [segue destinationViewController];
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



# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

@end
