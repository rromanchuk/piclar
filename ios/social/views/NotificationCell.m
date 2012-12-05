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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if(highlighted) {
        self.notificationLabel.backgroundColor = [UIColor clearColor];
    } else {
        self.notificationLabel.backgroundColor = [UIColor backgroundColor];
    }
    
    [super setHighlighted:highlighted animated:animated];
}


@end
