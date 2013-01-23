#import "Place.h"
#import "FeedItem.h"
#import "PhotoNewViewController.h"
#import "BaseCollectionViewController.h"
#import "PlaceShowHeader.h"
#import "CheckinViewController.h"
@interface PlaceShowViewController : BaseCollectionViewController <NSFetchedResultsControllerDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout, CreateCheckinDelegate, DeletionHandler>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) Place *place;
@property NSInteger headerHeight;
@property (strong, nonatomic) PlaceShowHeader *headerView;

- (IBAction)didCheckIn:(id)sender;
@end
