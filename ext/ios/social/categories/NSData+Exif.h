//
//  NSData+Exif.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/13/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSData (Exif)
- (NSMutableData *)addExifData;
- (NSMutableData *)addLocationExifData:(CLLocation *)location;
- (NSMutableData *)addExifData:(NSDictionary *)metaData;

@end
