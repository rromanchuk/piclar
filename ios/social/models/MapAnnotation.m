//
//  MapAnnotation.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/19/12.
//
//

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize address = _address;
@synthesize name = _name;
@synthesize coordinate = _coordinate;
@synthesize place;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

- (NSString *)subtitle {
    return _address;
}

@end
