//
//  ProfilePhotoView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import "User+Rest.h"
@interface ProfilePhotoView : UIView
@property NSNumber *thumbnailSize;
@property NSNumber *thumbnailSizeForDevice;
@property NSNumber *radius;
@property NSNumber *radiusForDevice;
@property (weak, nonatomic) UIImage *profileImage;
@property UIImageView *profileImageView;

- (void)setProfileImageWithUrl:(NSString *)url;
- (void)setProfileImageForUser:(User *)user;
@end
