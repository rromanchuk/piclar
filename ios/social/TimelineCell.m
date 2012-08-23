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
    
    CGContextMoveToPoint(ctx, 43.0, 0);
    CGContextAddLineToPoint(ctx, 43.0, self.bounds.size.height);
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
