//
//  FeedEmptyCell.m
//  Ostronaut
//
//  Created by Ivan Lazarev on 18.10.12.
//
//

#import "FeedEmptyCell.h"

@interface FeedEmptyCell ()

@end

@implementation FeedEmptyCell

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
