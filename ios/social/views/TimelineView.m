//
//  TimelineView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/20/12.
//
//

#import "TimelineView.h"

@implementation TimelineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 43.0, 0);
    CGContextAddLineToPoint(ctx, 43.0, self.bounds.size.height);
    CGContextStrokePath(ctx);
    
    
    CGRect indicatorRect = CGRectMake(40.0, 30.0, 6.0, 6.0);
    CGContextAddEllipseInRect(ctx, indicatorRect);
    
    CGContextSetFillColor(ctx, CGColorGetComponents([RGBCOLOR(255.0, 255.0, 255.0) CGColor]));
    CGContextEOFillPath(ctx);
    
    CGRect innerIndicatorRect = CGRectMake(41.0, 31.0, 4.0, 4.0);
    CGContextAddEllipseInRect(ctx, innerIndicatorRect);
    CGContextSetFillColor(ctx, CGColorGetComponents([RGBCOLOR(223.0, 223.0, 223.0) CGColor]));
    CGContextEOFillPath(ctx);
    [super drawRect:rect];
}


@end
