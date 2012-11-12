#import "Place.h"
#import "FeedItem.h"
#import "PhotoNewViewController.h"
#import "BaseCollectionViewController.h"
#import "PlaceShowHeader.h"

@interface PlaceShowViewController : BaseCollectionViewController <CreateCheckinDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;


@property (weak, nonatomic) FeedItem *feedItem;
@property (strong, nonatomic) PlaceShowHeader *headerView;


- (IBAction)didCheckIn:(id)sender;
@end
