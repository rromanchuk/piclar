
#import "CoreDataTableViewController.h"
#import "User.h"
@interface UserShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *user;
- (IBAction)didLogout:(id)sender;
@end
