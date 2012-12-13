//
//  FeedCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "FeedCell.h"

@implementation FeedCell

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
    self.titleLabel.textColor = [UIColor defaultFontColor];
    self.dateLabel.textColor = [UIColor minorFontColor];
    self.reviewLabel.textColor = [UIColor defaultFontColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setStars:(NSInteger)stars {
    self.star1.highlighted = YES;
    self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = NO;
    if (stars == 5) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = YES;
    } else if (stars == 4) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = YES;
    } else if (stars == 3) {
        self.star2.highlighted = self.star3.highlighted = YES;
    } else if (stars == 2) {
        self.star2.highlighted = YES;
    }
}

@end
