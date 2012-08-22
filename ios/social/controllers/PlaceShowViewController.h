#import "Place.h"
#import "FeedItem.h"
#import "CoreDataTableViewController.h"
#import "PlaceShowView.h"
@interface PlaceShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) FeedItem *feedItem;

//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *postCardPhoto;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView *photosScrollView;
@property (weak, nonatomic) IBOutlet UILabel *placeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UIImage *star1;
@property (weak, nonatomic) IBOutlet UIImage *star2;
@property (weak, nonatomic) IBOutlet UIImage *star3;
@property (weak, nonatomic) IBOutlet UIImage *star4;
@property (weak, nonatomic) IBOutlet UIImage *star5;
@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;
@property (weak, nonatomic) IBOutlet PlaceShowView *placeShowView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;

@end
