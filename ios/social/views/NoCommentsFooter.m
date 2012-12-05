//
//  NoCommentsFooter.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/29/12.
//
//

#import "NoCommentsFooter.h"

@implementation NoCommentsFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.noCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, frame.size.width, frame.size.height)];
        self.noCommentsLabel.text = NSLocalizedString(@"NO_COMMENTS", nil);
        self.noCommentsLabel.textColor = [UIColor defaultFontColor];
        self.noCommentsLabel.textAlignment = NSTextAlignmentCenter;
        self.noCommentsLabel.backgroundColor = [UIColor clearColor];
        self.noCommentsLabel.numberOfLines = 0;
        [self.noCommentsLabel sizeToFit];
        [self addSubview:self.noCommentsLabel];
        //self.backgroundColor = [UIColor redColor];
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
