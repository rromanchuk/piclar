//
//  UserProfileViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/15/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
#import "iCarousel.h"
#import "BaseViewController.h"
@protocol ProfileShowDelegate;

@interface UserProfileViewController : BaseViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *currentUser;

@property (nonatomic, strong) NSArray *checkins;


@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostcardsLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet iCarousel *carouselView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) id <ProfileShowDelegate> delegate;
- (IBAction)didFollowUnfollowUser:(id)sender;

@end


@protocol ProfileShowDelegate <NSObject>
@required
- (void)didDismissProfile;

@end