
#import "TimelineCell.h"
#import "BubbleCommentView.h"
@interface PostCardCell : TimelineCell
@property (nonatomic, weak) IBOutlet UIImageView *postcardPhoto;

@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UIView *profilePhotoBackdrop;

@property (nonatomic, weak) IBOutlet UILabel *postCardPlaceTitle;
@property (nonatomic, weak) IBOutlet UILabel *timeAgoInWords;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;


@end
