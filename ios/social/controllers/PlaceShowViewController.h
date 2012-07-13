

@interface PlaceShowViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableViewCell *placeCoverPhotoCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mapDetailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phonDetailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reviewDetailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *allReviewsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *photosDetailCell;

@end
