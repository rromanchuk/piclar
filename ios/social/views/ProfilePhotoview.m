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

- (void)setProfileImageWithUrl:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.profileImageView setImageWithURLRequest:request
                                              placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                           self.profileImage = image;
                                                       }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                           NSLog(@"Failure loading review profile photo with request %@ and errer %@", request, error);
                                                       }];

}

- (void)setProfileImage:(UIImage *)profileImage {
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
