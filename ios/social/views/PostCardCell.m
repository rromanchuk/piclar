//
//  PostCardCell.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostCardCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PostCardCell

@synthesize profilePhoto; 
@synthesize postcardPhoto; 
@synthesize dateLabel;
@synthesize monthLabel;
@synthesize postCardTitleLabel;
@synthesize postCardSubTitleLabel;
@synthesize commentLabel;
@synthesize addCommentButton;

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

- (void)reloadImage:(NSNotification *)notification
{
    [self setNeedsLayout];
}

@end
