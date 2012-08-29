
#import "CoreDataTableViewController.h"
#import "FeedItem.h"
#import "NewCommentCell.h"
#import "HPGrowingTextView.h"
#import "PhotoNewViewController.h"
@interface CommentNewViewController : CoreDataTableViewController <HPGrowingTextViewDelegate, CreateCheckinDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypePhoto;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLabel;
@property (nonatomic, weak) HPGrowingTextView *commentView;
@property (weak, nonatomic) UIView *footer;
- (IBAction)didAddComment:(id)sender event:(UIEvent *)event;
@end
