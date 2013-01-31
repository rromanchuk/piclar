//
//  BaseTableViewCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/8/12.
//
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        self.backgroundColor = RGBACOLOR(233, 214, 215, 0.55);
    } else {
        self.backgroundColor = [UIColor backgroundColor];
    }
    
    [super setHighlighted:highlighted animated:animated];
}

@end
