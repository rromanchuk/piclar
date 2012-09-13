//
//  RestUserSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "RestUserSettings.h"

@implementation RestUserSettings
@synthesize vkShare;
@synthesize saveFiltered;
@synthesize saveOriginal;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"saveOriginal", @"SETTINGS_STORE_ORIGINAL",
            @"saveFiltered", @"SETTINGS_STORE_FILTERED",
            @"vkShare", @"SETTINGS_VK_SHARE",
            nil];
}

@end
