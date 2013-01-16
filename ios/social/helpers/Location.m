#import "Location.h"
#import "Flurry.h"
#import <AddressBook/AddressBook.h>

@interface Location ()

@end


@implementation Location


- (id)init
{
    self = [super init];
    
    if (self) {
        self.locationManager                 = [[CLLocationManager alloc] init];
        self.locationManager.delegate        = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter  = 250;
        self.locationManager.purpose         = NSLocalizedString(@"LOCATION_EXPLANATION", @"Explain to the user why we need location");
        self.geoCoder = [[CLGeocoder alloc] init];
        self.useExifDataIfPresent = YES;
    }
    
    return self;
}

- (NSNumber *)getLatitude {
    if (self.latitudeFromExifData && self.useExifDataIfPresent) {
        return _latitudeFromExifData;
    } else {
        return _latitude;
    }
}

- (NSNumber *)getLongitude {
    if (self.longitudeFromExifData && self.useExifDataIfPresent) {
        return _longitudeFromExifData;
    } else {
        return _longitude;
    }
}

- (BOOL)exifDataAvailible {
    if (self.longitudeFromExifData) 
        return YES;
    return NO;
}

- (void)resetExifData {
    self.latitudeFromExifData = self.longitudeFromExifData = nil;
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
    
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        // store the location as the "best effort"
        self.bestEffortAtLocation = newLocation;
        // test the measurement to see if it meets the desired accuracy
        //
        // IMPORTANT!!! kCLLocationAccuracyBest should not be used for comparison with location coordinate or altitidue
        // accuracy because it is a negative value. Instead, compare against some predetermined "real" measure of
        // acceptable accuracy, or depend on the timeout to stop updating. This sample depends on the timeout.
        //
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            // we have a measurement that meets our requirements, so we can stop updating the location
            //
            // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
            //
            [self stopUpdatingLocation:@"Found a location that is within our desiredAccuracy"];
            // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
            
            self.desiredLocation = newLocation;
            CLLocationCoordinate2D coordinate = [newLocation coordinate];
            self.latitude  = [NSNumber numberWithDouble:coordinate.latitude];
            self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
            
            [Flurry setLatitude:newLocation.coordinate.latitude
                      longitude:newLocation.coordinate.longitude
             horizontalAccuracy:newLocation.horizontalAccuracy
               verticalAccuracy:newLocation.verticalAccuracy];
            
            [self.delegate didGetBestLocationOrTimeout];
        }
    }
    // update the display with the new location data
}

- (void)updateUntilDesiredOrTimeout:(NSTimeInterval)timeout {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:@"TimedOut" afterDelay:timeout];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self.delegate failedToGetLocation:error];
}


- (void)stopUpdatingLocation: (NSString *)state {
    DLog(@"Stoping location update with state: %@", state);
    DLog(@"delegate is %@", self.delegate);
    [self getCityCountry];
    [self.locationManager stopUpdatingLocation];
    if ([state isEqualToString:@"TimedOut"]) {
#warning all delgates should implement this  
        ALog(@"delegate is %@", self.delegate);
        if (self.delegate && [self.delegate respondsToSelector:@selector(locationStoppedUpdatingFromTimeout)]) {
            [self.delegate locationStoppedUpdatingFromTimeout];
        }
    
    }
}

- (void)resetDesiredLocation {
    self.desiredLocation = nil;
    self.bestEffortAtLocation = nil;
}

- (BOOL)isLocationValid {
    if (!self.longitude || ![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) {
        return NO;
    } else {
        return YES;
    }

}

- (void)getCityCountry {
    
    [self.geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.cityCountryString = [NSString stringWithFormat:@"%@, %@", [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey], [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryKey]];
            ALog(@"got address %@", self.cityCountryString);
        }
    }];

}
@end