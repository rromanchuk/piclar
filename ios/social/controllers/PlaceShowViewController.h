#import "Place.h"
#import "CoreDataTableViewController.h"

@interface PlaceShowViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) Place *place;

@end
