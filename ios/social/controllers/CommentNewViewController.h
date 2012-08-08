
#import "CoreDataTableViewController.h"
#import "FeedItem.h"

@interface CommentNewViewController : CoreDataTableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@end
