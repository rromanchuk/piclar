#import "Place.h"
#import "FeedItem.h"
#import "PhotoNewViewController.h"
#import "BaseCollectionViewController.h"
#import "PlaceShowHeader.h"

@interface PlaceShowViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, CreateCheckinDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;
@property (strong, nonatomic) FeedItem *feedItem;
@property (strong, nonatomic) Place *place;

@property (strong, nonatomic) PlaceShowHeader *headerView;


- (IBAction)didCheckIn:(id)sender;
@end
