#import "Place.h"
#import "FeedItem.h"
#import "CoreDataTableViewController.h"
#import "PhotoNewViewController.h"
#import "BaseCollectionViewController.h"
#import "PlaceShowHeader.h"
@interface PlaceShowViewController : BaseCollectionViewController <CreateCheckinDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) FeedItem *feedItem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) PlaceShowHeader *headerView;


- (IBAction)didCheckIn:(id)sender;
@end
