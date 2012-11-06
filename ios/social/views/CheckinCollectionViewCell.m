//
//  CheckinCollectionViewCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "CheckinCollectionViewCell.h"

@implementation CheckinCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [photo setContentMode:UIViewContentModeScaleAspectFill];
        [photo setClipsToBounds:YES];
        self.photo = photo;
        [self.contentView addSubview:self.photo];
        
        ALog(@"init with frame cell");
        //self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Add your subviews here
        // self.contentView for content
        // self.backgroundView for the cell background
        // self.selectedBackgroundView for the selected cell background
        ALog(@"IN INIT WITH CODER FOR CELL VIEW");

    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.photo.image = nil;
    self.checkinPhoto.image = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
