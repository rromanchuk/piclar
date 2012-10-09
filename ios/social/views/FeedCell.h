//
//  FeedCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "ProfilePhotoView.h"
#import "TTTAttributedLabel.h"
@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *checkinPhoto;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)setCheckinPhotoWithURL:(NSString *)url;
- (void)setStars:(NSInteger)stars;

@end
