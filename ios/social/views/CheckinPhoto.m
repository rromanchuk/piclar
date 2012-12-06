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
#import "Photo+Rest.h"
#import "UIImage+Resize.h"
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
    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
    [self.layer setShadowColor:[UIColor grayColor].CGColor];
    [self.layer setShadowOpacity:0.8];
    [self.layer setShadowRadius:1.0];
    [self.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width/2) - 10, (self.frame.size.height / 2) - 10, 20.0, 20.0) ];
    [self addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidesWhenStopped:YES];
    self.activityIndicator.backgroundColor = RGBCOLOR(197, 197, 197);
    self.activityIndicator.opaque = YES;
    self.opaque = YES;
    self.backgroundColor = RGBCOLOR(197, 197, 197);
}

- (void)setCheckinPhotoWithURL:(NSString *)url {
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self setImageWithURLRequest:postcardRequest
                placeholderImage:nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [self.activityIndicator stopAnimating];
                             self.image = image;
                             
                         }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             [self.activityIndicator stopAnimating];
                             DLog(@"Failure setting postcard image with url %@", url);
                         }];
}



- (void)setLargeCheckinImageForCheckin:(Photo *)photo withContext:(NSManagedObjectContext *)context{
    
//    if (photo.largeImage) {
//        [self.activityIndicator stopAnimating];
//        self.image = [UIImage imageWithData:photo.largeImage];;
//    } else {
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.url]];
//        [self setImageWithURLRequest:request
//                                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]
//                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                  [self.activityIndicator stopAnimating];
//                                                
//                                                  NSData *imageData = UIImagePNGRepresentation(image);
//                                                  photo.largeImage = imageData;
//                                                      
//                                                  
//                                                  self.image = image;
//                                                  
//                                              }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                  [self.activityIndicator stopAnimating];
//                                                  DLog(@"Failure setting postcard image with url %@", url);
//                                              }];
//        
//    }
}


- (void)setThumbnailCheckinImageForCheckin:(Photo *)photo {
//    if (checkin.thumbnailImage) {
//        [self.activityIndicator stopAnimating];
//        UIImage *image = [UIImage imageWithData:checkin.thumbnailImage];
//        self.image = image;
//    } else if (checkin.largeImage) {
//        [self.activityIndicator stopAnimating];
//        UIImage *image = [UIImage imageWithData:checkin.largeImage];
//        image = [image resizedImage:CGSizeMake(196, 196) interpolationQuality:kCGInterpolationHigh];
//        checkin.thumbnailImage = UIImagePNGRepresentation(image);
//        self.image = image;
//    } else {
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[checkin firstPhoto].url]];
//        [self setImageWithURLRequest:request
//                    placeholderImage:[UIImage imageNamed:@"placeholder.png"]
//                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                 [self.activityIndicator stopAnimating];
//                                 checkin.largeImage = UIImagePNGRepresentation(image);
//                                 image = [image resizedImage:CGSizeMake(196, 196) interpolationQuality:kCGInterpolationHigh];
//                                 checkin.thumbnailImage = UIImagePNGRepresentation(image);
//                                 self.image = image;
//                                 
//                             }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                 [self.activityIndicator stopAnimating];
//                                 DLog(@"Failure setting postcard image with url %@", url);
//                             }];
//        
//    }
}



@end
