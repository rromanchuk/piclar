//
//  SpeechBubble.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/22/12.
//
//

#import "SpeechBubble.h"

@implementation SpeechBubble

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
    // Drawing code
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 5, 0);
    CGContextAddLineToPoint(ctx, 5.0, 10.0);
    CGContextAddLineToPoint(ctx, 0.0, 12.5);
    CGContextAddLineToPoint(ctx, 5.0, 15.0);
    CGContextAddLineToPoint(ctx, 5.0, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    CGContextAddLineToPoint(ctx, 5, 0);
    CGContextStrokePath(ctx);
    
    UIColor *backgroundColor = RGBACOLOR(247.0, 247.0, 247.0, 1.0);
    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    //CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
}


@end
