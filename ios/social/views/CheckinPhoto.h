//
//  CheckinPhoto.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/9/12.
//
//

#import "Checkin+Rest.h"

@interface CheckinPhoto : UIImageView
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
- (void)setCheckinPhotoWithURL:(NSString *)url;
- (void)setCheckinPhotoWithURLForceReload:(NSString *)url;
- (void)setLargeCheckinImageForCheckin:(Photo *)photo withContext:(NSManagedObjectContext *)context;
- (void)setThumbnailCheckinImageForCheckin:(Photo *)photo;
@end
