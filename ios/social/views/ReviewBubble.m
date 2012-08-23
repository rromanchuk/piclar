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
    [super drawRect:rect];
    NSLog(@"review: w:%f h:%f x:%f y:%f", rect.size.width, rect.size.height, rect.origin.x, rect.origin.y);
    float lineWidth = 0.5;
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [RGBACOLOR(247.0, 247.0, 247.0, 1.0) setFill];
    [RGBCOLOR(198, 198, 198) setStroke];
    [aPath setLineWidth:lineWidth];
    [aPath moveToPoint:CGPointMake(0.0, 5.0 )];
    [aPath addLineToPoint:CGPointMake(30.0, 5.0 )];
    [aPath addLineToPoint:CGPointMake(30.0, 0.0 )];
    [aPath addLineToPoint:CGPointMake(35.0, 5 )];
    [aPath addLineToPoint:CGPointMake(rect.size.width, 5.0 )];
    [aPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [aPath addLineToPoint:CGPointMake(0.0, rect.size.height)];
    [aPath closePath];
    [aPath fill];
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:CGPointMake(0, 5)];
    [bPath addLineToPoint:CGPointMake(0, rect.size.height)];
    [bPath stroke];
    
    if (self.isLastComment){
        UIBezierPath *cPath = [UIBezierPath bezierPath];
        [cPath moveToPoint:CGPointMake(0, rect.size.height)];
        [cPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
        [cPath stroke];
    } else {
        UIBezierPath *cPath = [UIBezierPath bezierPath];
        [cPath moveToPoint:CGPointMake(4, rect.size.height)];
        [cPath addLineToPoint:CGPointMake(rect.size.width - 4.0, rect.size.height)];
        [cPath stroke];
    }
    
    UIBezierPath *dPath = [UIBezierPath bezierPath];
    [dPath moveToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [dPath addLineToPoint:CGPointMake(rect.size.width, 5)];
    [dPath stroke];
    
    UIBezierPath *ePath = [UIBezierPath bezierPath];
    [ePath setLineWidth:0.5];
    [ePath moveToPoint:CGPointMake(0, 5)];
    [ePath addLineToPoint:CGPointMake(30, 5)];
    [ePath addLineToPoint:CGPointMake(30, 0)];
    [ePath addLineToPoint:CGPointMake(35, 5)];
    [ePath addLineToPoint:CGPointMake(rect.size.width, 5)];
    [ePath stroke];
    
}

@end
