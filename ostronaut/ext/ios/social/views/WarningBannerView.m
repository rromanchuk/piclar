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
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.frame;
    
    UIColor *colorOne = RGBACOLOR(164, 16, 16, 1);
    UIColor *colorTwo = RGBACOLOR(118, 12, 7, 1);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    gradientLayer.colors = colors;
    //gradientLayer.opacity = 0.7;
    gradientLayer.startPoint = CGPointMake(0.0, 0.3);
    gradientLayer.endPoint = CGPointMake(0.0, 1);
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    self.warningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning.png"]];
    [self.warningImage setFrame:CGRectMake(20, (self.frame.size.height / 2) - (self.warningImage.frame.size.height / 2), self.warningImage.frame.size.width, self.warningImage.frame.size.height)];
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.warningImage.frame.origin.x + self.warningImage.frame.size.width) + 10, (self.frame.size.height/2) / 2 , self.frame.size.width - ((self.warningImage.frame.origin.x + self.warningImage.frame.size.width) + 10), self.frame.size.height/2)];
    self.descriptionLabel.backgroundColor = [UIColor yellowColor];
    self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    self.descriptionLabel.textColor = RGBCOLOR(255, 255, 255);
    self.descriptionLabel.text = NSLocalizedString(@"NO_CONNECTION", @"Warning message when user has no internet connection");
    self.descriptionLabel.textAlignment = UITextAlignmentCenter;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.numberOfLines = 1;
    self.descriptionLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.warningImage];
    [self addSubview:self.descriptionLabel];

}
@end
