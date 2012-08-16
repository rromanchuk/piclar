#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PostCardImageView.h"
#import "CheckinCreateViewController.h"

@protocol CheckinCreateViewControllerDelegate;
@interface PlaceSearchViewController : CoreDataTableViewController <LocationDelegate> {
    BOOL isFetchingResults;
    float lastAccuracy;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) id <CheckinCreateViewControllerDelegate> delegate;

@end


@protocol CheckinCreateViewControllerDelegate <NSObject>
@required
- (void)didSelectNewPlace:(Place *)newPlace;
@end