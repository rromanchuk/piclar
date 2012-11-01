//
//  CheckinPhoto.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/9/12.
//
//

#import "CheckinPhoto.h"
#import  <QuartzCore/QuartzCore.h>
#import "Config.h"
@implementation CheckinPhoto

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self.layer setShadowColor:[UIColor grayColor].CGColor];
    [self.layer setShadowOpacity:0.8];
    [self.layer setShadowRadius:1.0];
    [self.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width/2) - 10, (self.frame.size.height / 2) - 10, 20.0, 20.0) ];
    [self addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidesWhenStopped:YES];

}

- (void)setCheckinPhotoWithURL:(NSString *)url {
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self setImageWithURLRequest:postcardRequest
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [self.activityIndicator stopAnimating];
                             if (response.statusCode != 0 && ![Config sharedConfig].isSlowDevice) {
                                 self.alpha = 0.0;
                                 self.image = image;
                                 [UIView animateWithDuration:2.0 animations:^{
                                     self.alpha = 1.0;
                                 }];
                             }
                         }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             [self.activityIndicator stopAnimating];
                             DLog(@"Failure setting postcard image with url %@", url);
                         }];
}


@end
