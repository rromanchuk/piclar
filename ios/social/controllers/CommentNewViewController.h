

@interface CommentNewViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
