//
//  NewCommentCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfilePhotoView.h"
#import "CommentWithLeftIndicatorView.h"
@interface NewCommentCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userCommentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeInWordsLabel;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhotoView;
@property (weak, nonatomic) IBOutlet CommentWithLeftIndicatorView *commentView;

@end
