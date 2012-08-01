
#import "TimelineCell.h"

@interface PostCardCell : TimelineCell
@property (nonatomic, weak) IBOutlet UIImageView *postcardPhoto;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto;
@property (nonatomic, weak) IBOutlet UILabel *postCardUserName;
@property (nonatomic, weak) IBOutlet UILabel *postCheckedInAtText;
@property (nonatomic, weak) IBOutlet UILabel *postCardPlaceTitle;

@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;

@end
