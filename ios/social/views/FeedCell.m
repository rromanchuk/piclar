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

- (void)setCheckinPhotoWithURL:(NSString *)url {
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.checkinPhoto setImageWithURLRequest:postcardRequest
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [self.activityIndicator stopAnimating];
                             if (response.statusCode != 0) {
                                 self.checkinPhoto.alpha = 0.0;
                                 self.checkinPhoto.image = image;
                                 [UIView animateWithDuration:2.0 animations:^{
                                     self.checkinPhoto.alpha = 1.0;
                                 }];
                             }
                         }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             DLog(@"Failure setting postcard image with url %@", url);
                         }];
}

- (void)setStars:(NSInteger)stars {
    self.star1.highlighted = YES;
    self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = NO;
    if (stars == 5) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = YES;
    } else if (stars == 4) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = YES;
    } else if (stars == 3) {
        self.star2.highlighted = self.star3.highlighted = YES;
    } else {
        self.star2.highlighted = YES;
    }
}

@end
