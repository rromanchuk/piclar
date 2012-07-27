
#import "TimelineCell.h"

@interface PostCardCell : TimelineCell
@property (nonatomic, weak) IBOutlet UIImageView *postcardPhoto;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto;
@property (nonatomic, weak) IBOutlet UILabel *postCardTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *postCardSubTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton; 

@end
