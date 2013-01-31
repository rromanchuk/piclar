//
//  FriendsIndexCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/22/12.
//
//

#import "FriendsIndexCell.h"

@implementation FriendsIndexCell
@synthesize userNameLabel;
@synthesize userLocationLabel;
@synthesize userProfilePhotoView;

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
