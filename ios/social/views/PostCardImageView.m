//
//  PostCardImageView.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import "PostCardImageView.h"
#import  <QuartzCore/QuartzCore.h>

@implementation PostCardImageView
@synthesize activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.layer setBorderWidth: 2.0];
        [self.layer setShadowColor:[UIColor grayColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:1.0];
        [self.layer setShadowOffset:CGSizeMake(1.0, 2.0)];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width/2) - 10, (self.frame.size.height / 2) - 10, 20.0, 20.0) ];
        [self addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        [self.activityIndicator setHidesWhenStopped:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [self.layer setBorderWidth: 2.0];
        [self.layer setShadowColor:[UIColor grayColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:1.0];
        [self.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    }
    return self;
}

- (void)setPostcardPhotoWithURL:(NSString *)url {
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self setImageWithURLRequest:postcardRequest
                              placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [self.activityIndicator stopAnimating];
                                       }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"Failure setting postcard image with url %@", url);
                                       }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
