//
//  SmallProfilePhoto.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/14/12.
//
//

#import "SmallProfilePhoto.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"

@implementation SmallProfilePhoto

- (void)setProfileImageForUser:(User *)user {
    if (user.smallProfilePhoto) {
        ALog(@"Loading profile photo from disk");
        UIImage *image = [UIImage imageWithData:user.smallProfilePhoto];
        ALog(@"size of photo is is %f", image.size.width );
        self.profileImageView.image = image;
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:user.remoteProfilePhotoUrl]];
        [self.profileImageView setImageWithURLRequest:request
                                     placeholderImage:[UIImage imageNamed:@"placeholder-profile.png"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  ALog(@"resizing to %f", [self.thumbnailSizeForDevice floatValue]);
                                                  image = [SmallProfilePhoto roundImage:image thumbnailSizeForDevize:[self.thumbnailSizeForDevice floatValue] radiusForDevice:[self.radiusForDevice floatValue]];
                                                  NSData *imageData = UIImagePNGRepresentation(image);
                                                  user.smallProfilePhoto = imageData;
                                                  self.profileImageView.image = image;
                                                  
                                              }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  self.profileImage = [UIImage imageNamed:@"placeholder-profile.png"];
                                                  ALog(@"Failure loading review profile photo with request %@ and errer %@", request, error);
                                              }];
        
    }
}



@end
