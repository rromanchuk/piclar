#import "Place.h"
#import "CoreDataTableViewController.h"

@interface PlaceShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) Place *place;

//Outlets
@property (weak, nonatomic) IBOutlet UIImageView *postCardPhoto;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView *photosScrollView;


- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;

@end
