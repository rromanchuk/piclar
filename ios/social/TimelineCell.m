//
//  TimelineCell.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimelineCell.h"

@implementation TimelineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 35.0, 0);
    CGContextAddLineToPoint(ctx, 35.0, self.bounds.size.height);
    CGContextStrokePath(ctx);
    
    
    CGRect indicatorRect = CGRectMake(32.5, 13.0, 5.0, 5.0);
    CGContextAddEllipseInRect(ctx, indicatorRect);
//    CGContextAddEllipseInRect(ctx, 
//                              CGRectMake(
//                                         rect.origin.x + 10, 
//                                         rect.origin.y + 10, 
//                                         rect.size.width - 20, 
//                                         rect.size.height - 20));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor blueColor] CGColor]));
    CGContextEOFillPath(ctx);
    
    [super drawRect:rect];
}

@end
