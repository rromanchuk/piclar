#import "Location.h"

@implementation Location

@synthesize locationManager;
@synthesize latitude; 
@synthesize longitude; 
@synthesize delegate;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.locationManager                 = [[CLLocationManager alloc] init];
        self.locationManager.delegate        = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        self.locationManager.distanceFilter  = 250;
        self.locationManager.purpose         = NSLocalizedString(@"LOCATION_EXPLANATION", @"Explain to the user why we need location");
    }
    
    return self;
}


- (void)update
{
    [self.locationManager startUpdatingLocation];
}

+ (Location *)sharedLocation
{
    static dispatch_once_t pred;
    static Location *sharedLocation;
    
    dispatch_once(&pred, ^{
        sharedLocation = [[Location alloc] init];
    });
    
    return sharedLocation;
}

// CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)aLocationManager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    
    CLLocationCoordinate2D coordinate = [newLocation coordinate];
    
    self.latitude  = coordinate.latitude;
    self.longitude = coordinate.longitude;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self.delegate failedToGetLocation:error];
}



@end
