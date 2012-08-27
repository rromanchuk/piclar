//
//  SearchFriendsCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import "SearchFriendsCell.h"

@implementation SearchFriendsCell
@synthesize searchTypeLabel;
@synthesize descriptionLabel;
@synthesize searchTypePhoto;

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
