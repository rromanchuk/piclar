#import "Place.h"
#import "FeedItem.h"
#import "PhotoNewViewController.h"
#import "BaseCollectionViewController.h"
#import "PlaceShowHeader.h"

@interface PlaceShowViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, CreateCheckinDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) IBOutlet PSUICollectionView *collectionView;

@property (strong, nonatomic) PlaceShowHeader *headerView;


- (IBAction)didCheckIn:(id)sender;
@end
