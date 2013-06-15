//
//  FeedCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "TTTAttributedLabel.h"
#import "CheckinPhoto.h"
#import "SmallProfilePhoto.h"
@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet SmallProfilePhoto *profileImage;


@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;



@end
