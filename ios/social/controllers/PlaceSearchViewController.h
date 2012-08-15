#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PostCardImageView.h"
@interface PlaceSearchViewController : CoreDataTableViewController <LocationDelegate> {
    BOOL isFetchingResults;
    float lastAccuracy;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
