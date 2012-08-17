//
//  UserComment.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/12/12.
//
//

#import "UserComment.h"
#import "BubbleCommentView.h"
@implementation UserComment

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBACOLOR(247.0, 247.0, 247.0, 1.0);
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 4.0, 0.0);
    CGContextAddLineToPoint(ctx, self.frame.size.width - 4.0, 0.0);
    CGContextStrokePath(ctx);
}

@end
