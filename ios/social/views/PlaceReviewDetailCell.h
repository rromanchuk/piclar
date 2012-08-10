//
//  PlaceReviewDetailCell.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceReviewDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel; 
@property (weak, nonatomic) IBOutlet UILabel *authorLabel; 
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto; 

@end
