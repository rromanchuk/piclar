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

@synthesize postcardPhoto; 
@synthesize postCardPlaceTitle;
@synthesize timeAgoInWords;

@synthesize addCommentButton;
@synthesize favoriteButton;
@synthesize profilePhotoBackdrop;
@synthesize starsImageView;
@synthesize shareButton;
@synthesize placeTypeImageView;
@synthesize reviewTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {

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
