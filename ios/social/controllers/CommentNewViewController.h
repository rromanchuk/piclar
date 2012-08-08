
#import "CoreDataTableViewController.h"
@interface CommentNewViewController : CoreDataTableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
