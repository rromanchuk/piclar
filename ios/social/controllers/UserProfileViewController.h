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

@interface UserProfileViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *checkins;


@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostcardsLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@end
