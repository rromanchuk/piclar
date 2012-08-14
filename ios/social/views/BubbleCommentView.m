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
@synthesize profilePhoto;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0, 5.0, 240.0, 60.0)];
        ProfilePhotoView *_profilePhoto = [[ProfilePhotoView alloc] initWithFrame:CGRectMake(5.0, 3.0, 23.0, 23.0)];
        self.profilePhoto = _profilePhoto; 
        self.commentLabel = _commentLabel;
        [self addSubview:self.profilePhoto];
        [self addSubview:self.commentLabel];
        self.backgroundColor = RGBCOLOR(247.0, 247.0, 247.0);
        self.commentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:11.0];
    }
    return self;
}

@end
