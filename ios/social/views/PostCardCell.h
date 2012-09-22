
#import "TimelineCell.h"
#import "ProfilePhotoView.h"
#import "PostCardImageView.h"
@interface PostCardCell : TimelineCell

@property (nonatomic, weak) IBOutlet PostCardImageView *postcardPhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhotoBackdrop;
@property (nonatomic, weak) IBOutlet UILabel *postCardPlaceTitle;
@property (nonatomic, weak) IBOutlet UILabel *timeAgoInWords;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *reviewTextLabel;
@property (weak, nonatomic) IBOutlet UIView *reviewView;


@property (weak, nonatomic) IBOutlet UIView *commentsView;
@property (weak, nonatomic) IBOutlet UILabel *comment1Label;
@property (weak, nonatomic) IBOutlet UILabel *comment2Label;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *comment1ProfilePhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *comment2ProfilePhoto;
@property (weak, nonatomic) IBOutlet UIButton *seeMoreCommentsButton;

@end
