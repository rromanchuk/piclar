//
//  FeedCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "TTTAttributedLabel.h"
#import "CheckinPhoto.h"
@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsDescriptionLabel;



@end
