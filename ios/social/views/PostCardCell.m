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
@synthesize postCardPlaceTitle;
@synthesize timeAgoInWords;

@synthesize addCommentButton;
@synthesize favoriteButton;
@synthesize star1, star2, star3, star4, star5;
@synthesize profilePhotoBackdrop;
@synthesize starsImageView;

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
        NSLog(@"adding gradient");
        CALayer *layer = self.layer;
        //layer.frame = self.view.frame;
        //layer.cornerRadius = 10.0;
        //layer.masksToBounds = YES;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.frame;
        
        UIColor *colorOne = RGBACOLOR(239.0, 239.0, 239.0, 1.0);
        UIColor *colorTwo = RGBACOLOR(249.0, 249.0, 249.0, 1.0);
        
        NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
        gradientLayer.colors = colors;
        //[layer addSublayer:gradientLayer];
        //[layer insertSublayer:gradientLayer atIndex:0];

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
