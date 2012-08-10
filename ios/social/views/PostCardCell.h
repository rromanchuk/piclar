
#import "TimelineCell.h"
#import "BubbleCommentView.h"
@interface PostCardCell : TimelineCell
@property (nonatomic, weak) IBOutlet UIImageView *postcardPhoto;

@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UIView *profilePhotoBackdrop;

@property (nonatomic, weak) IBOutlet UILabel *postCardPlaceTitle;
@property (nonatomic, weak) IBOutlet UILabel *timeAgoInWords;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *userCommentLabel;
@property (nonatomic, weak) IBOutlet BubbleCommentView *userCommentBubble;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;


@property (nonatomic, weak) IBOutlet UIButton *star1; 
@property (nonatomic, weak) IBOutlet UIButton *star2;
@property (nonatomic, weak) IBOutlet UIButton *star3;
@property (nonatomic, weak) IBOutlet UIButton *star4;
@property (nonatomic, weak) IBOutlet UIButton *star5;


@end
