//
//  NotificationCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/12/12.
//
//

#import "NotificationCell.h"

@implementation NotificationCell
@synthesize notificationLabel;
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