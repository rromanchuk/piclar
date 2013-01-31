//
//  PlaceShowFeedCollectionCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/12/12.
//
//

#import "CheckinPhoto.h"

@interface PlaceShowFeedCollectionCell : PSUICollectionViewCell
@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;

@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;

- (void)setStars:(NSInteger)stars;
@end
