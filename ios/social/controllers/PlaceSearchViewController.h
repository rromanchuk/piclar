#import "CoreDataTableViewController.h"
#import "Location.h"
#import "PostCardImageView.h"
@interface PlaceSearchViewController : CoreDataTableViewController <LocationDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) UIImage *filteredImage;
@property (weak, nonatomic) IBOutlet PostCardImageView *postcardPhoto;

@end
