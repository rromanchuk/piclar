//
//  BaseView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/17/12.
//
//

#import "BaseView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//        gradientLayer.frame = self.frame;
//        
//        UIColor *colorOne = RGBACOLOR(239.0, 239.0, 239.0, 1.0);
//        UIColor *colorTwo = RGBACOLOR(249.0, 249.0, 249.0, 1.0);
//        
//        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
//        gradientLayer.colors = colors;
//        [self.layer insertSublayer:gradientLayer atIndex:0];
        [self commonInit];
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
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    
//    CGGradientRef glossGradient;
//    CGColorSpaceRef rgbColorspace;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 239.0 / 255.0, 239.0 / 255.0, 239.0 / 255.0, 1.0,  // Start color
//        248.0 / 255.0, 248.0 / 255.0, 248.0 / 255.0, 1.0 }; // End color
//    
//    rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
//    
//    CGRect currentBounds = self.bounds;
//    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
//    CGPoint bottomCent = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
//    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCent, 0);
//    
//    CGGradientRelease(glossGradient);
//    CGColorSpaceRelease(rgbColorspace);
//}


@end
