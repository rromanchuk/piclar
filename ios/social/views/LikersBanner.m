//
//  LikersBanner.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/19/12.
//
//

#import "LikersBanner.h"
#import "SmallProfilePhoto.h"
@implementation LikersBanner {
    NSMutableArray *likerViews;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    
    self.backgroundColor = [UIColor clearColor];
    //9x14
    self.disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray-arrow"]];
    ALog(@"height of image is %f and frame %f", self.disclosureIndicator.frame.size.height, self.frame.size.height);
    [self.disclosureIndicator setFrame:CGRectMake(self.frame.size.width - self.disclosureIndicator.frame.size.width - 10, (self.frame.size.height / 2) - (self.disclosureIndicator.frame.size.height / 2), self.disclosureIndicator.frame.size.width, self.disclosureIndicator.frame.size.height)];
    
    [self addSubview:self.disclosureIndicator];
    
    
}

- (void)layoutViewForLikers:(NSSet *)likers {
    self.likers = likers;
    
    for (ProfilePhotoView *view in likerViews) {
        [view removeFromSuperview];
    }
    
    likerViews = [[NSMutableArray alloc] init];
    int xOffset = 10;
    int numLikers = 0;
    for (User *liker in self.likers) {
        SmallProfilePhoto *likerPhoto = [[SmallProfilePhoto alloc] initWithFrame:CGRectMake(xOffset, (self.frame.size.height / 2) - (38 / 2), 38, 38)];
        [likerPhoto setProfileImageForUser:liker];
        likerPhoto.tag = 99;
        [likerViews addObject:likerPhoto];
        [self addSubview:likerPhoto];
        xOffset = (xOffset + 38) + 5;
        if (numLikers > 3)
            break;
        numLikers++; 
    }
    
    if ([self.likers count] == 0) {
        self.disclosureIndicator.hidden = YES;
        self.userInteractionEnabled = NO;
    } else {
        self.disclosureIndicator.hidden = NO;
        self.userInteractionEnabled = YES;
    }

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
