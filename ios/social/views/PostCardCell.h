
#import "TimelineCell.h"
#import "BubbleCommentView.h"
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

@end
