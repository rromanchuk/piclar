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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;

@end
