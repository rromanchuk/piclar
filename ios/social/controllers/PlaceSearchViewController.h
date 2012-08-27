#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PostCardImageView.h"
#import "CheckinCreateViewController.h"

@protocol CheckinCreateViewControllerDelegate;
@interface PlaceSearchViewController : UITableViewController <LocationDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, MKMapViewDelegate> {
    BOOL isFetchingResults;
    float lastAccuracy;
    int locationFailureCount;
    // required ivars for this example
    NSFetchedResultsController *fetchedResultsController_;
    NSFetchedResultsController *searchFetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *_tableView;

@property (weak, nonatomic) id <CheckinCreateViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;


@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;

- (IBAction)dismissModal:(id)sender;
@end


@protocol CheckinCreateViewControllerDelegate <NSObject>
@required
- (void)didSelectNewPlace:(Place *)newPlace;
@end