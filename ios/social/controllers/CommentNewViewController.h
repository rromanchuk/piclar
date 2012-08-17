
#import "CoreDataTableViewController.h"
#import "FeedItem.h"
#import "NewCommentCell.h"
@interface CommentNewViewController : CoreDataTableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypePhoto;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLabel;
@property (nonatomic, weak) UITextField *commentTextField;
- (IBAction)didAddComment:(id)sender event:(UIEvent *)event;
@end
