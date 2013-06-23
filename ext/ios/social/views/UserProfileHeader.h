//
//  UserProfileHeader.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "ProfilePhotoView.h"
@interface UserProfileHeader : UICollectionReusableView

@property (strong, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *numPostcardsLabel;
@property (strong, nonatomic) IBOutlet UIButton *followersButton;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UIButton *switchLayoutButton;

@end
