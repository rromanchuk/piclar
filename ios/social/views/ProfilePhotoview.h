//
//  ProfilePhotoView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/14/12.
//
//

#import <UIKit/UIKit.h>

@interface ProfilePhotoView : UIView
@property NSNumber *thumbnailSize;
@property NSNumber *thumbnailSizeForDevice;
@property NSNumber *radius;
@property NSNumber *radiusForDevice;
@property (weak, nonatomic) UIImage *profileImage;
@property UIImageView *profileImageView;

@end
