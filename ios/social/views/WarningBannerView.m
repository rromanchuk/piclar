//
//  WarningBannerView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/4/12.
//
//

#import "WarningBannerView.h"

@implementation WarningBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.alpha = 1.0;
        self.backgroundColor = [UIColor blackColor];
        
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
        
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 12)];
        description.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        description.textColor = RGBCOLOR(138, 138, 138);
        description.text = @"Не получилось обновить ленту";
        description.textAlignment = UITextAlignmentCenter;
        description.backgroundColor = [UIColor clearColor];
        [self addSubview:description];
    }
    
    return self;
}

@end
