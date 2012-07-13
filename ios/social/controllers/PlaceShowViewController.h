
#import "PlaceCoverPhotoCell.h"
#import "PlaceMapDetailCell.h"
#import "PlacePhoneDetailCell.h"
#import "PlaceReviewDetailCell.h"
#import "PlaceAllReviewsDetailCell.h"
#import "PlacePhotosDetailCell.h"
@interface PlaceShowViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet PlaceCoverPhotoCell *placeCoverPhotoCell;
@property (weak, nonatomic) IBOutlet PlaceMapDetailCell *mapDetailCell;
@property (weak, nonatomic) IBOutlet PlacePhoneDetailCell *phonDetailCell;
@property (weak, nonatomic) IBOutlet PlaceReviewDetailCell *reviewDetailCell;
@property (weak, nonatomic) IBOutlet PlaceAllReviewsDetailCell *allReviewsCell;
@property (weak, nonatomic) IBOutlet PlacePhotosDetailCell *photosDetailCell;

@end
