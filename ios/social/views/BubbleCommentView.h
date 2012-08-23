//
//  BubbleCommentView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfilePhotoView.h"
@interface BubbleCommentView : UIView
@property BOOL isLastComment;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet ProfilePhotoView *profilePhoto;
- (void)setProfilePhotoWithUrl:(NSString *)url;
- (void)setCommentText:(NSString *)comment;
- (void)setReviewText:(NSString *)text;
@end
