#import "CoreDataTableViewController.h"
#import "Location.h"

@interface PlaceSearchViewController : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Location *location;

@end
