//
//  UserProfileHeader.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
@interface UserProfileHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostcardsLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *switchLayoutButton;

@end
