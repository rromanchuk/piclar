//
//  NewCommentPlaceDetailCell.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCommentPlaceDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel; 
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel; 
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel; 
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@end
