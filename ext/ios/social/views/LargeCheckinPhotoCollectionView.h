//
//  LargeCheckinPhotoCollectionView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/10/12.
//
//

#import <UIKit/UIKit.h>
#import "CheckinPhoto.h"
@interface LargeCheckinPhotoCollectionView : PSUICollectionViewCell
@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;


@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
- (void)setStars:(NSInteger)stars;
@end
