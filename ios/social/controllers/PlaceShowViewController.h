#import "Place.h"
#import "FeedItem.h"
#import "CoreDataTableViewController.h"
#import "PlaceShowView.h"
#import "PostCardImageView.h"
#import "PhotoNewViewController.h"
@interface PlaceShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CreateCheckinDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *photos;

@property (weak, nonatomic) FeedItem *feedItem;
@property (weak, nonatomic) UIImage *star0;
@property (weak, nonatomic) UIImage *star1;
@property (weak, nonatomic) UIImage *star2;
@property (weak, nonatomic) UIImage *star3;
@property (weak, nonatomic) UIImage *star4;
@property (weak, nonatomic) UIImage *star5;


//Outlets
@property (weak, nonatomic) IBOutlet PostCardImageView *postCardPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView *photosScrollView;
@property (weak, nonatomic) IBOutlet UILabel *placeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;
@property (weak, nonatomic) IBOutlet PlaceShowView *placeShowView;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImageView;


- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;
- (IBAction)didCheckIn:(id)sender;
@end
