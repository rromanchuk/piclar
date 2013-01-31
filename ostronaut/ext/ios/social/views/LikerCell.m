//
//  LikerCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import "LikerCell.h"

@implementation LikerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    self.nameLabel.textColor = [UIColor defaultFontColor];
    self.locationLabel.textColor = [UIColor minorFontColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if(highlighted) {
        self.locationLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
    } else {
        self.locationLabel.backgroundColor = [UIColor backgroundColor];
        self.nameLabel.backgroundColor = [UIColor backgroundColor];
    }
    
    [super setHighlighted:highlighted animated:animated];
}

@end
