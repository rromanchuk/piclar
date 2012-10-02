//
//  WarningBannerView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/4/12.
//
//

#import "WarningBannerView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WarningBannerView
@synthesize descriptionLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andMessage:(NSString *)message {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        self.descriptionLabel.text = message;
    }
    
    return self;
}

- (void)commonInit {
    self.opaque = NO;
    self.alpha = 7.0;
    //self.backgroundColor = [UIColor blackColor];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.frame;
    
    UIColor *colorOne = RGBACOLOR(223, 223, 223, 1);
    UIColor *colorTwo = RGBACOLOR(182, 182, 182, 1);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    gradientLayer.colors = colors;
    //gradientLayer.opacity = 0.7;
    gradientLayer.startPoint = CGPointMake(0.0, 0.3);
    gradientLayer.endPoint = CGPointMake(0.0, 1);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height/2) / 2 , self.frame.size.width, self.frame.size.height/2)];
    self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    self.descriptionLabel.textColor = RGBCOLOR(138, 138, 138);
    self.descriptionLabel.text = @"Не получилось обновить ленту";
    self.descriptionLabel.textAlignment = UITextAlignmentCenter;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.numberOfLines = 1;
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.descriptionLabel];

}
@end
