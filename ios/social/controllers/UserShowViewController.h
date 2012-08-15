
#import "CoreDataTableViewController.h"
#import "User.h"
#import "ProfilePhotoView.h"
@interface UserShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;

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

- (IBAction)didLogout:(id)sender;
@end
