//
//  PlaceShowView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/17/12.
//
//

#import "PlaceShowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlaceShowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.frame;
        
        UIColor *colorOne = RGBACOLOR(239.0, 239.0, 239.0, 1.0);
        UIColor *colorTwo = RGBACOLOR(249.0, 249.0, 249.0, 1.0);
        
        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
        gradientLayer.colors = colors;
        [self.layer insertSublayer:gradientLayer atIndex:0];

    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
//        NSLog(@"adding gradient");
//        
//        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//        gradientLayer.frame = self.frame;
//        
//        UIColor *colorOne = RGBACOLOR(239.0, 239.0, 239.0, 1.0);
//        UIColor *colorTwo = RGBACOLOR(249.0, 249.0, 249.0, 1.0);
//        
//        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
//        gradientLayer.colors = colors;
//        [self.layer insertSublayer:gradientLayer atIndex:0];
    }
    return self;
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
