//
//  FriendsIndexCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/22/12.
//
//

#import "ProfilePhotoView.h"

@interface FriendsIndexCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLocationLabel;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *userProfilePhotoView;

@end
