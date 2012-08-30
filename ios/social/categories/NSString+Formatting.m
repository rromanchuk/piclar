//
//  NSString+Formatting.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/30/12.
//
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)
- (NSString *)removeNewlines {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
}
@end
