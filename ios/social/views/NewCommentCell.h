//
//  NewCommentCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmallProfilePhoto.h"
#import "TTTAttributedLabel.h"
@interface NewCommentCell : UITableViewCell
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *userCommentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeInWordsLabel;
@property (weak, nonatomic) IBOutlet SmallProfilePhoto *profilePhotoView;

@end
