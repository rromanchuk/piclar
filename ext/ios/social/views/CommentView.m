//
//  CommentView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/24/12.
//
//

#import "CommentView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor:RGBCOLOR(198, 198, 198).CGColor];
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
