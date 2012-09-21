
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@protocol LocationDelegate <NSObject>
@required
- (void)didGetBestLocationOrTimeout;
- (void)locationStoppedUpdatingFromTimeout;
@optional
- (void)didGetLocation;
- (void)failedToGetLocation:(NSError *)error;

@end


@interface Location : NSObject <CLLocationManagerDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) id<LocationDelegate> delegate;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) CLLocation *desiredLocation;

- (void)update;
- (void)updateUntilDesiredOrTimeout:(NSTimeInterval)timeout;
- (void)resetDesiredLocation;
+ (Location *)sharedLocation;
- (void)stopUpdatingLocation: (NSString *)state;
@end
