//
//  UIFont+DEFAULTS.m
//  Piclar
//
//  Created by Ryan Romanchuk on 6/23/13.
//
//

#import "UIFont+DEFAULTS.h"

@implementation UIFont (DEFAULTS)
+ (UIFont *)defaultFont:(NSInteger)size {
    for (NSString *familyName in [UIFont familyNames]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"%@", fontName);
        }
    }
    return [UIFont fontWithName:@"PTSans-Regular" size:size];
}
@end
