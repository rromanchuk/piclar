//
//  PlaceSearchCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/13/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@interface PlaceSearchCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *placePhoto;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLabel;

@end
