//
//  PostCardImageView.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//


@interface PostCardImageView : UIImageView
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)setPostcardPhotoWithURL:(NSString *)url;
@end
