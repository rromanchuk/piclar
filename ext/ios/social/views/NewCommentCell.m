//
//  NewCommentCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewCommentCell.h"

@implementation NewCommentCell
@synthesize userCommentLabel; 
@synthesize timeInWordsLabel; 
@synthesize profilePhotoView;

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

@end
