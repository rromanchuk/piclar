//
//  NSData+Exif.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 12/13/12.
//
//

#import "NSData+Exif.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import <ImageIO/ImageIO.h>
#import "Location.h"

@implementation NSData (Exif)
- (NSMutableData *)addExifData {
    
    
    CGImageSourceRef  source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    
    //get all the metadata in the image
    NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    
    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
       
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!EXIFDictionary) {
        //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
        EXIFDictionary = [NSMutableDictionary dictionary];
    }
    if(!GPSDictionary) {
        GPSDictionary = [NSMutableDictionary dictionary];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[Location sharedLocation].latitude doubleValue] longitude:[[Location sharedLocation].longitude doubleValue]];
        [GPSDictionary setLocation:location];
    }
    
    //Setup GPS dict
    
//    [GPSDictionary setValue:[NSNumber numberWithFloat:_lat] forKey:(NSString*)kCGImagePropertyGPSLatitude];
//    [GPSDictionary setValue:[NSNumber numberWithFloat:_lon] forKey:(NSString*)kCGImagePropertyGPSLongitude];
//    [GPSDictionary setValue:lat_ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
//    [GPSDictionary setValue:lon_ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
//    [GPSDictionary setValue:[NSNumber numberWithFloat:_alt] forKey:(NSString*)kCGImagePropertyGPSAltitude];
//    [GPSDictionary setValue:[NSNumber numberWithShort:alt_ref] forKey:(NSString*)kCGImagePropertyGPSAltitudeRef];
//    [GPSDictionary setValue:[NSNumber numberWithFloat:_heading] forKey:(NSString*)kCGImagePropertyGPSImgDirection];
//    [GPSDictionary setValue:[NSString stringWithFormat:@"%c",_headingRef] forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
    
    //[EXIFDictionary setValue:xml forKey:(NSString *)kCGImagePropertyExifUserComment];
    //add our modified EXIF data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        ALog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        ALog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    //[dest_data writeToFile:file atomically:YES];
    
    //cleanup
    
    
    CFRelease(destination);
    CFRelease(source);
    
    return dest_data;
}

- (NSMutableData *)addLocationExifData:(CLLocation *)location {
    
    CGImageSourceRef  source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    
    //get all the metadata in the image
    NSDictionary *metadata = (__bridge NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    
    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    [metadataAsMutable setLocation:location];
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        ALog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        ALog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    //[dest_data writeToFile:file atomically:YES];
    
    //cleanup
    
    
    CFRelease(destination);
    CFRelease(source);
    
    return dest_data;

}

- (NSMutableData *)addExifData:(NSMutableDictionary *)metaData {
    CGImageSourceRef  source;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    
        
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        ALog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metaData);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        ALog(@"***Could not create data from image destination ***");
    }
    
    
    CFRelease(destination);
    CFRelease(source);
    
    return dest_data;
}


@end
