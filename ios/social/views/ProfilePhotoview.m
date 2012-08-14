//
//  ProfilePhotoView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/14/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "ProfilePhotoView.h"
#import "Utils.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"

@implementation ProfilePhotoView
@synthesize thumbnailSize, thumbnailSizeForDevice;
@synthesize radius, radiusForDevice;
@synthesize profileImage = _profileImage;
@synthesize profileImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *pinkColor = RGBCOLOR(242, 95, 114);
        CALayer *backdropLayer = self.layer;
        [backdropLayer setCornerRadius:self.frame.size.width / 2];
        [backdropLayer setBorderWidth:1];
        [backdropLayer setBorderColor:[pinkColor CGColor]];
        [backdropLayer setMasksToBounds:YES];
        
        self.thumbnailSize = [NSNumber numberWithFloat:(self.frame.size.height - 4.0)];
        self.thumbnailSizeForDevice = [NSNumber numberWithFloat:[Utils sizeForDevice:[self.thumbnailSize floatValue]]];
        self.radius = [NSNumber numberWithFloat:([self.thumbnailSize floatValue]/ 2.0)];
        self.radiusForDevice = [NSNumber numberWithFloat:[Utils sizeForDevice:[self.radius floatValue]]];
        
        float padding = (self.frame.size.width - (self.frame.size.width - 4.0)) /2;
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, self.frame.size.width - 4.0, self.frame.size.height - 4.0)];
        [self addSubview:self.profileImageView];
        self.profileImageView.image = self.profileImage;
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        UIColor *pinkColor = RGBCOLOR(242, 95, 114);
        CALayer *backdropLayer = self.layer;
        NSLog(@"Width of frame is %f", self.frame.size.width);
        [backdropLayer setCornerRadius:self.frame.size.width / 2];
        [backdropLayer setBorderWidth:1];
        [backdropLayer setBorderColor:[pinkColor CGColor]];
        [backdropLayer setMasksToBounds:YES];
        
        self.thumbnailSize = [NSNumber numberWithFloat:(self.frame.size.height - 4.0)];
        self.thumbnailSizeForDevice = [NSNumber numberWithFloat:[Utils sizeForDevice:[self.thumbnailSize floatValue]]];
        self.radius = [NSNumber numberWithFloat:([self.thumbnailSize floatValue]/ 2.0)];
        self.radiusForDevice = [NSNumber numberWithFloat:[Utils sizeForDevice:[self.radius floatValue]]];
        
        float padding = (self.frame.size.width - (self.frame.size.width - 4.0)) /2;
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, self.frame.size.width - 4.0, self.frame.size.height - 4.0)];
        [self addSubview:self.profileImageView];
        self.profileImageView.image = self.profileImage;

    }
    return self;
}


- (void)setProfileImage:(UIImage *)profileImage {
    NSLog(@"Setting profile image with radius %@ and thumbnail size %@", self.radiusForDevice, self.thumbnailSizeForDevice);
    self.profileImageView.image = [profileImage thumbnailImage:[self.thumbnailSizeForDevice floatValue] transparentBorder:0 cornerRadius:[self.radiusForDevice floatValue] interpolationQuality:kCGInterpolationHigh];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
