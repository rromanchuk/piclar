//
//  ReviewBubble.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/12/12.
//
//

#import "ReviewBubble.h"
#define USER_REVIEW_PADDING 3.0f

@implementation ReviewBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:NO];
        self.backgroundColor = [UIColor clearColor];
        
        // We are using 5px to add a custom frame within the view we need to pull down these elements
        CGRect profilePhotoFrame = self.profilePhoto.frame;
        profilePhotoFrame.origin.y = profilePhotoFrame.origin.y + 5.0;
        self.profilePhoto.frame = profilePhotoFrame;
        
        CGRect commentLabelFrame = self.commentLabel.frame;
        commentLabelFrame.origin.y = commentLabelFrame.origin.y + 5;
        self.commentLabel.frame = commentLabelFrame;
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
    
    CGContextMoveToPoint(ctx, 0, 5.0);
    CGContextAddLineToPoint(ctx, 30.0, 5.0);
    CGContextAddLineToPoint(ctx, 30.0, 0.0);
    //CGContextFillPath(ctx);
    //CGContextStrokePath(ctx);
    
    //CGContextMoveToPoint(ctx, 30.0, 0.0);
    CGContextAddLineToPoint(ctx, 35.0, 5.0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 5.0);
    //CGContextStrokePath(ctx);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 5.0);
    //CGContextFillPath(ctx);
    CGContextStrokePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 247.0, 247.0, 247.0, 1.0);
    CGContextMoveToPoint(ctx, 0, 5.0);
    CGContextAddLineToPoint(ctx, 30.0, 5.0);
    CGContextAddLineToPoint(ctx, 30.0, 0.0);
    CGContextAddLineToPoint(ctx, 35.0, 5.0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 5.0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height);
    CGContextAddLineToPoint(ctx, 0.0, self.frame.size.height);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
//    
//    CGContextAddLineToPoint(ctx, 10.0, -10.0);
//    //CGContextStrokePath(ctx);
//    CGContextAddLineToPoint(ctx, 13.0, 0.0);
//    //CGContextStrokePath(ctx);
//    CGContextAddLineToPoint(ctx, self.frame.size.width, 0.0);
//    CGContextStrokePath(ctx);
}

@end
