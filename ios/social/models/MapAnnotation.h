//
//  MapAnnotation.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/19/12.
//
//
#import <MapKit/MapKit.h>
#import "Place.h"
@interface MapAnnotation : NSObject <MKAnnotation>

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, strong) Place *place;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
@end
