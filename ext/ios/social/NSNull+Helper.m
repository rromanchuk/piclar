//
//  NSNull+Helper.m
//  Piclar
//
//  Created by Ryan Romanchuk on 2/25/13.
//
//

#import "NSNull+Helper.h"

@implementation NSNull (Helper)
+ (id)nullWhenNil:(id)obj {
    
    return (obj ? obj : [self null]);
    
}
@end
