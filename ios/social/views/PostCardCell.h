
#import "TimelineCell.h"
#import "BubbleCommentView.h"
#import "ProfilePhotoView.h"
@interface PostCardCell : TimelineCell

@property (nonatomic, weak) IBOutlet UIImageView *postcardPhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhotoBackdrop;
@property (nonatomic, weak) IBOutlet UILabel *postCardPlaceTitle;
@property (nonatomic, weak) IBOutlet UILabel *timeAgoInWords;
@property (nonatomic, weak) IBOutlet UIButton *addCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *starsImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImageView;

- (void)setPostcardPhotoWithURL:(NSString *)url;
@end
