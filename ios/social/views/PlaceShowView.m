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
@synthesize hasScrollView;
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




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 43.0, 0);
    if (self.hasScrollView) {
        CGContextAddLineToPoint(ctx, 43.0, self.bounds.size.height - 85);
    } else {
        CGContextAddLineToPoint(ctx, 43.0, self.bounds.size.height);
    }
    
    CGContextStrokePath(ctx);
    
    
    CGRect indicatorRect = CGRectMake(40.0, 30.0, 6.0, 6.0);
    CGContextAddEllipseInRect(ctx, indicatorRect);
    CGContextSetFillColor(ctx, CGColorGetComponents([RGBCOLOR(255.0, 255.0, 255.0) CGColor]));
    CGContextEOFillPath(ctx);
    
    CGContextSaveGState(ctx);
    CGContextSetShadow(ctx, CGSizeMake(0,2), 5);
    //CGContextRestoreGState(ctx);
    
    CGRect innerIndicatorRect = CGRectMake(41.0, 31.0, 4.0, 4.0);
    CGContextAddEllipseInRect(ctx, innerIndicatorRect);
    CGContextSetFillColor(ctx, CGColorGetComponents([RGBCOLOR(223.0, 223.0, 223.0) CGColor]));
    CGContextEOFillPath(ctx);
    [super drawRect:rect];

}


@end
