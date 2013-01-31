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

- (NSString *)removeSpaces {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (NSString *)truncatedQuote {
    NSString *str = [self substringToIndex: MIN(76, [self length])];
    if ([self length] < 76) {
        return [NSString stringWithFormat:@"«%@»", str];
    } else {
        return [NSString stringWithFormat:@"«%@...»", str];
    }
    
}

@end
