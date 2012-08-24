//
//  CommentWithLeftIndicatorView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/17/12.
//
//

#import <UIKit/UIKit.h>

@interface CommentWithLeftIndicatorView : UIView
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *commentLabel;
@property (strong, nonatomic) UILabel *timeAgoInWordsLabel;
- (void)setCommentText:(NSString *)comment;
@end
