//
//  BubbleCommentView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BubbleCommentView.h"

@implementation BubbleCommentView
@synthesize commentLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 240.0, 60.0)];
        self.commentLabel = _commentLabel;
        [self addSubview:self.commentLabel];
        self.backgroundColor = RGBCOLOR(247.0, 247.0, 247.0);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
