#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PlaceCreateViewController.h"

@protocol PlaceSearchDelegate;

@interface PlaceSearchViewController : BaseTableView <LocationDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, MKMapViewDelegate, PlaceCreateDelegate> {
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

//iboutlets
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *_tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

// delegates
@property (weak, nonatomic) id <PlaceSearchDelegate> placeSearchDelegate;



@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

- (IBAction)dismissModal:(id)sender;
@end


@protocol PlaceSearchDelegate <NSObject>
@required
- (void)didSelectNewPlace:(Place *)newPlace;
- (void)wantsToCreateNewPlace;

@end