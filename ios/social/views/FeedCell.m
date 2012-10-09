//
//  FeedCell.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "FeedCell.h"

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPostcardPhotoWithURL:(NSString *)url {
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.imageView setImageWithURLRequest:postcardRequest
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             //[self.activityIndicator stopAnimating];
                             if (response.statusCode != 0) {
                                 self.imageView.alpha = 0.0;
                                 self.imageView.image = image;
                                 [UIView animateWithDuration:2.0 animations:^{
                                     self.alpha = 1.0;
                                 }];
                             }
                         }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             DLog(@"Failure setting postcard image with url %@", url);
                         }];
}


@end
