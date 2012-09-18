//
//  CommentHeader.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/18/12.
//
//

#import "CommentHeader.h"

@implementation CommentHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    DLog(@"ostrich");
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [RGBCOLOR(198, 198, 198) setStroke];
    //[[UIColor redColor] setStroke];
    float lineWidth = 0.5;
    [aPath setLineWidth:lineWidth];
    [aPath moveToPoint:CGPointMake(0.0, rect.size.height - lineWidth)];
    [aPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height - lineWidth)];
    [aPath stroke];
}


@end
