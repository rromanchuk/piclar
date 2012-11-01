//
//  CheckinCollectionViewCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "CheckinPhoto.h"
@interface CheckinCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet CheckinPhoto *checkinPhoto;

@end
