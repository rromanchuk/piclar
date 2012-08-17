//
//  BubbleCommentView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BubbleCommentView.h"
#define USER_COMMENT_PADDING 3.0f
#define USER_COMMENT_LEFT_PADDING 5.0f

#define PROFILE_PHOTO_LEFT_PADDING 5.0f
#define PROFILE_PHOTO_SIZE 23.0f

#define REVIEW_MARGIN_OFFSET 5.0f

@implementation BubbleCommentView
@synthesize commentLabel;
@synthesize profilePhoto;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ProfilePhotoView *_profilePhoto = [[ProfilePhotoView alloc] initWithFrame:CGRectMake(PROFILE_PHOTO_LEFT_PADDING, USER_COMMENT_PADDING, PROFILE_PHOTO_SIZE, PROFILE_PHOTO_SIZE)];
        self.profilePhoto = _profilePhoto; 
        [self addSubview:self.profilePhoto];
        
        UILabel *_commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profilePhoto.frame.origin.x + self.profilePhoto.frame.size.width + USER_COMMENT_LEFT_PADDING, USER_COMMENT_PADDING, frame.size.width - (self.profilePhoto.frame.origin.x + profilePhoto.frame.size.width + PROFILE_PHOTO_LEFT_PADDING), 60.0)];
        self.commentLabel = _commentLabel;
        [self addSubview:self.commentLabel];
        self.backgroundColor = RGBCOLOR(247.0, 247.0, 247.0);
        self.commentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:11.0];
        self.tag = 999;
    }
    return self;
}


- (void)setReviewText:(NSString *)text {
    self.commentLabel.text = text;
    self.backgroundColor = [UIColor greenColor];
    self.commentLabel.backgroundColor = [UIColor yellowColor];
    float minimumHeight = self.profilePhoto.frame.origin.y + self.profilePhoto.frame.size.height + USER_COMMENT_PADDING;
    CGSize expectedReviewLabelSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font
                                                        constrainedToSize:self.commentLabel.frame.size
                                                            lineBreakMode:UILineBreakModeWordWrap];
    
    float expectedFrameSize =  expectedReviewLabelSize.height + (USER_COMMENT_PADDING * 2) + REVIEW_MARGIN_OFFSET;
    if (minimumHeight > expectedFrameSize) {
        expectedFrameSize = minimumHeight;
    }
    
    NSLog(@"Expected size of label %f", expectedReviewLabelSize.height);
    CGRect resizedReviewBubbleFrame = self.frame;
    resizedReviewBubbleFrame.size.height = expectedFrameSize;
    self.frame = resizedReviewBubbleFrame;
    
    CGRect resizedReviewLabelFrame = self.commentLabel.frame;
    resizedReviewLabelFrame.size.height = expectedReviewLabelSize.height;
    self.commentLabel.frame = resizedReviewLabelFrame;
    self.commentLabel.numberOfLines = 0;
    [self.commentLabel sizeToFit];
    NSLog(@" Size of frame is %f", self.frame.size.height);
    
}

- (void)setCommentText:(NSString *)comment {
    self.commentLabel.text = comment;
    self.backgroundColor = [UIColor greenColor];
    self.commentLabel.backgroundColor = [UIColor yellowColor];
    float minimumHeight = self.profilePhoto.frame.origin.y + self.profilePhoto.frame.size.height + USER_COMMENT_PADDING;
    CGSize expectedReviewLabelSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font
                                                        constrainedToSize:self.commentLabel.frame.size
                                                            lineBreakMode:UILineBreakModeWordWrap];
    
    float expectedFrameSize =  expectedReviewLabelSize.height + (USER_COMMENT_PADDING * 2);
    if (minimumHeight > expectedFrameSize) {
        expectedFrameSize = minimumHeight;
    }
    
    NSLog(@"Expected size of label %f", expectedReviewLabelSize.height);
    CGRect resizedReviewBubbleFrame = self.frame;
    resizedReviewBubbleFrame.size.height = expectedFrameSize;
    self.frame = resizedReviewBubbleFrame;
    
    CGRect resizedReviewLabelFrame = self.commentLabel.frame;
    resizedReviewLabelFrame.size.height = expectedReviewLabelSize.height;
    self.commentLabel.frame = resizedReviewLabelFrame;
    self.commentLabel.numberOfLines = 0;
    [self.commentLabel sizeToFit];
    NSLog(@" Size of frame is %f", self.frame.size.height);

}

- (void)setProfilePhotoWithUrl:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.profilePhoto.profileImageView setImageWithURLRequest:request
                                                       placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                    self.profilePhoto.profileImage = image;
                                                                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                    NSLog(@"Failure loading review profile photo with request %@ and errer %@", request, error);
                                                                }];
}

@end
