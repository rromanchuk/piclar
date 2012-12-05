//
//  BaseView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/17/12.
//
//

#import "BaseView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    self.backgroundColor = [UIColor backgroundColor];
}




@end
