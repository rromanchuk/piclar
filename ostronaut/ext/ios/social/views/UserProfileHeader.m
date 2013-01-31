//
//  UserProfileHeader.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import "UserProfileHeader.h"

@implementation UserProfileHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        ALog(@"IN INIT WITH FRAME FOR HEADER VIEW");
        
        self.followersButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followersButton setBackgroundImage:[UIImage imageNamed:@"followers.png"] forState:UIControlStateNormal];
        [self.followersButton setFrame:CGRectMake(20, 19, 67, 68)];
        [self.followersButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 19, 0)];
        [self.followersButton setTitleColor:RGBCOLOR(127, 127, 127) forState:UIControlStateNormal];
        self.followersButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        [self addSubview:self.followersButton];
        
        self.profilePhoto = [[ProfilePhotoView alloc] initWithFrame:CGRectMake(114, 5, 95, 95)];
        self.profilePhoto.backgroundColor = [UIColor blueColor];
        [self addSubview:self.profilePhoto];
        

        
        self.followingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followingButton setBackgroundImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
        [self.followingButton setFrame:CGRectMake(223, 19, 67, 68)];
        [self.followingButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 19, 0)];
        [self.followingButton setTitleColor:RGBCOLOR(127, 127, 127) forState:UIControlStateNormal];
        self.followingButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        [self addSubview:self.followingButton];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 101, 320, 21)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 115, 320, 21)];
        self.locationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        self.locationLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.locationLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateSelected];
        [self.followButton setFrame:CGRectMake(65, 141, 190, 49)];
        self.followButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];        self.followButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [self addSubview:self.followButton];
        
        self.switchLayoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.switchLayoutButton setBackgroundImage:[UIImage imageNamed:@"photo_grid.png"] forState:UIControlStateNormal];
        [self.switchLayoutButton setBackgroundImage:[UIImage imageNamed:@"photo_feed.png"] forState:UIControlStateSelected];
        [self.switchLayoutButton setFrame:CGRectMake(4, 193, 313, 49)];
        [self.switchLayoutButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 100)];
        self.switchLayoutButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold"  size:17];
        [self.switchLayoutButton setTitleColor:RGBCOLOR(127, 127, 127) forState:UIControlStateNormal];
        [self addSubview:self.switchLayoutButton];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ALog(@"IN INIT WITH CODER FOR HEADER VIEW");
        // Add your subviews here
        // self.contentView for content
        // self.backgroundView for the cell background
        // self.selectedBackgroundView for the selected cell background
    }
    return self;
}
//- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    layoutAttributes.frame = CGRectMake(0.0, 0.0, 320, 80);
//
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
