//
//  UIDeviceHardware.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/31/12.
//
//

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject

- (NSString *) platform;
- (NSString *) platformString;
- (BOOL)isSlowDevice;

@end