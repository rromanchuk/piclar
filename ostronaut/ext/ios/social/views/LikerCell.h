//
//  LikerCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "SmallProfilePhoto.h"
@interface LikerCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet SmallProfilePhoto *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@end
