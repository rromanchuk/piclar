//
//  LoadMoreFooter.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/14/12.
//
//

#import "LoadMoreFooter.h"

@implementation LoadMoreFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        int heightWidth = frame.size.height - 10;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width / 2) - heightWidth, 5, heightWidth, heightWidth)];
        self.activityIndicator.hidesWhenStopped = YES;
        
        self.loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.activityIndicator.frame.origin.x + self.activityIndicator.frame.size.width + 5, self.activityIndicator.frame.origin.y, frame.size.width - (self.activityIndicator.frame.origin.x - self.activityIndicator.frame.size.width), self.activityIndicator.frame.size.height)];
        self.loadMoreLabel.text = NSLocalizedString(@"LOADING", nil);
        self.loadMoreLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.activityIndicator];
        [self addSubview:self.loadMoreLabel];
        [self.activityIndicator startAnimating];
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
