//
//  NotificationBanner.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/30/12.
//
//

#import "NotificationBanner.h"
#import <QuartzCore/QuartzCore.h>

@implementation NotificationBanner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    self.opaque = NO;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.frame;
    
    UIColor *colorOne = RGBACOLOR(43, 146, 204, 0.8);
    UIColor *colorTwo = RGBACOLOR(65, 170, 230, 0.8);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    gradientLayer.colors = colors;
    //gradientLayer.opacity = 0.7;
    gradientLayer.startPoint = CGPointMake(0.0, 0.3);
    gradientLayer.endPoint = CGPointMake(0.0, 1);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}


- (void)setupView {
    NSURL *url = [NSURL URLWithString:self.user.remoteProfilePhotoUrl];
    [self.imageView setImageWithURL:url];
}


@end
