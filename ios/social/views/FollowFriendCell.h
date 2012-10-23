//
//  FollowFriendCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/24/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
@interface FollowFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mutualFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhotoView;
@end
