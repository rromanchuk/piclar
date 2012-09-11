
#import "CoreDataTableViewController.h"
#import "User.h"
#import "ProfilePhotoView.h"
@protocol ProfileShowDelegate;
@interface UserShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, NetworkReachabilityDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *mutualFriends;

@property (weak, nonatomic) IBOutlet ProfilePhotoView *userProfilePhotoViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *userNameHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocationHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *userFollowingHeaderButton;
@property (weak, nonatomic) IBOutlet UIButton *userMutualFollowingHeaderButton;


@property (nonatomic, weak) UIImage *placeHolderImage;
@property (nonatomic, weak) UIImage *star1;
@property (nonatomic, weak) UIImage *star2;
@property (nonatomic, weak) UIImage *star3;
@property (nonatomic, weak) UIImage *star4;
@property (nonatomic, weak) UIImage *star5;

@property (weak, nonatomic) id <ProfileShowDelegate> delegate;

- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;
- (void)networkReachabilityDidChange:(BOOL)connected;

@end


@protocol ProfileShowDelegate <NSObject>
@required
- (void)didDismissProfile;

@end