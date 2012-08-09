//
//  PostCardImageView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import "PostCardImageView.h"
#import  <QuartzCore/QuartzCore.h>

@implementation PostCardImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.layer setBorderWidth: 2.0];
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
