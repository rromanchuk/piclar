
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@protocol LocationDelegate <NSObject>
@required
- (void)didGetLocation;
- (void)failedToGetLocation:(NSError *)error;
@end


@interface Location : NSObject <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) id<LocationDelegate> delegate;

- (void)update;
+ (Location *)sharedLocation;
@end
