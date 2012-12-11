#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PlaceCreateViewController.h"
#import "WarningBannerView.h"
@protocol PlaceSearchDelegate;

@interface PlaceSearchViewController : BaseTableView <LocationDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, MKMapViewDelegate, PlaceCreateDelegate> {
    BOOL isFetchingResults;
    float lastAccuracy;
    int locationFailureCount;
    NSFetchedResultsController *fetchedResultsController_;
    NSFetchedResultsController *searchFetchedResultsController_;
    // The saved state of the search UI if a memory warning removed the view.
    NSString        *savedSearchTerm_;
    NSInteger       savedScopeButtonIndex_;
    BOOL            searchWasActive_;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) WarningBannerView *warningBanner;
@property (nonatomic) BOOL beganUpdates;
@property (nonatomic) BOOL desiredLocationFound;
@property (nonatomic) BOOL resultsFound;

//iboutlets
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *_tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationOnButton;

// delegates
@property (weak, nonatomic) id <PlaceSearchDelegate> placeSearchDelegate;


@property (strong, nonatomic) NSString *savedSearchTerm;
@property NSInteger savedScopeButtonIndex;
@property BOOL searchWasActive;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

- (IBAction)currentLocationToggle:(id)sender;
- (IBAction)dismissModal:(id)sender;
@end


@protocol PlaceSearchDelegate <NSObject>
@required
- (void)didSelectNewPlace:(Place *)newPlace;

@end