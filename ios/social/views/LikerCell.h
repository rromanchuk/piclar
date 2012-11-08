//
//  LikerCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
#import "BaseTableViewCell.h"

@interface LikerCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
