//
//  NewCommentCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCommentCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userCommentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeInWordsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto; 

@end
