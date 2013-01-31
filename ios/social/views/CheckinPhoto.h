//
//  CheckinPhoto.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/9/12.
//
//

@interface CheckinPhoto : UIImageView
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
- (void)setCheckinPhotoWithURL:(NSString *)url;
//- (void)setLargeCheckinImageForCheckin:(Photo *)photo withContext:(NSManagedObjectContext *)context;
//- (void)setThumbnailCheckinImageForCheckin:(Photo *)photo;
@end
