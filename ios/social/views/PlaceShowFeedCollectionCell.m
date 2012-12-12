//
//  PlaceShowFeedCollectionCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/12/12.
//
//

#import "PlaceShowFeedCollectionCell.h"

@implementation PlaceShowFeedCollectionCell
- (void)setStars:(NSInteger)stars {
    self.star1.highlighted = YES;
    self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = NO;
    if (stars == 5) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = YES;
    } else if (stars == 4) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = YES;
    } else if (stars == 3) {
        self.star2.highlighted = self.star3.highlighted = YES;
    } else {
        self.star2.highlighted = YES;
    }
}

@end
