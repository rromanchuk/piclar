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
    DLog(@"comment: w:%f h:%f x:%f y:%f", rect.size.width, rect.size.height, rect.origin.x, rect.origin.y);

    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [RGBCOLOR(198, 198, 198) setStroke];
    [RGBACOLOR(247.0, 247.0, 247.0, 1.0) setFill];
    float lineWidth = 1.0;
    [aPath setLineWidth:lineWidth];
    [aPath moveToPoint:CGPointMake(0.0, 0.0)];
    [aPath addLineToPoint:CGPointMake(0.0, rect.size.height)];
    [aPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    [aPath addLineToPoint:CGPointMake(rect.size.width, 0.0)];
    [aPath closePath];
    [aPath fill];
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint:CGPointMake(0, 0)];
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
    [dPath addLineToPoint:CGPointMake(rect.size.width, 0)];
    [dPath stroke];
}

@end
