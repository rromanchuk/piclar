
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
@property (nonatomic, strong, getter = getLatitude) NSNumber *latitude;
@property (nonatomic, strong, getter = getLongitude) NSNumber *longitude;


@property (nonatomic, assign) id<LocationDelegate> delegate;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, retain) CLLocation *desiredLocation;
@property BOOL isFetchingFromServer;
@property (strong, nonatomic) NSString *cityCountryString;
@property (strong, nonatomic) CLGeocoder *geoCoder;

- (void)update;
- (void)updateUntilDesiredOrTimeout:(NSTimeInterval)timeout;
- (void)resetDesiredLocation;
+ (Location *)sharedLocation;
- (void)stopUpdatingLocation: (NSString *)state;
- (BOOL)isLocationValid;

- (void)getCityCountryWithLat:(double)lat andLon:(double)lon success:(void (^)(NSString *cityCountry))success;

@end
