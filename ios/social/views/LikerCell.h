//
//  LikerCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
@interface LikerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhoto;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
