//
//  CommentWithLeftIndicatorView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/17/12.
//
//

#import "CommentWithLeftIndicatorView.h"

#define USER_COMMENT_PADDING 3.0f

@implementation CommentWithLeftIndicatorView
@synthesize usernameLabel;
@synthesize commentLabel;
@synthesize timeAgoInWordsLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

//- (id)initWithCoder:(NSCoder*)aDecoder
//{
//    if(self = [super initWithCoder:aDecoder])
//    {
//        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 5, self.frame.origin.y + 5, self.frame.size.width - 5, 10)];
//        self.usernameLabel.backgroundColor = [UIColor redColor];
//        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x + 5, self.usernameLabel.frame.origin.y + self.usernameLabel.frame.size.height + 5, self.usernameLabel.frame.size.width, 20)];
//        self.commentLabel.backgroundColor = [UIColor blueColor];
//        self.backgroundColor = [UIColor grayColor];
//        self.timeAgoInWordsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.usernameLabel.frame.origin.x, self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + 5, self.usernameLabel.frame.size.width, self.usernameLabel.frame.size.height)];
//
//    }
//    return self;
//}


- (void)setCommentText:(NSString *)comment {
    self.commentLabel.text = comment;
    //self.backgroundColor = [UIColor greenColor];
    //self.commentLabel.backgroundColor = [UIColor yellowColor];
   
    CGSize expectedCommentLabelSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font
                                                        constrainedToSize:self.commentLabel.frame.size
                                                            lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect resizedCommentFrame = self.commentLabel.frame;
    resizedCommentFrame.size.height = expectedCommentLabelSize.height;
    self.commentLabel.frame = resizedCommentFrame;
    self.commentLabel.numberOfLines = 0;
    [self.commentLabel sizeToFit];
    NSLog(@" Size of frame is %f", self.frame.size.height);
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.clipsToBounds = NO;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // Use the same color and width as the default cell separator for now
    CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1.0);
    UIColor *backgroundColor = RGBCOLOR(251.0, 251.0, 251.0);
    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    CGContextSetLineWidth(ctx, 0.25);
    
    CGContextMoveToPoint(ctx, 5, 0);
    CGContextAddLineToPoint(ctx, 5.0, 10.0);
    CGContextAddLineToPoint(ctx, 0.0, 12.5);
    CGContextAddLineToPoint(ctx, 5.0, 15.0);
    CGContextAddLineToPoint(ctx, 5.0, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    CGContextAddLineToPoint(ctx, 5, 0);
   
    
    
    CGContextClosePath(ctx);
    //CGContextFillPath(ctx);
    //CGContextStrokePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}


@end
