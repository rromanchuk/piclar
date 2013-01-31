//
//  UIColor+Ostronaut.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/29/12.
//
//

#import "UIColor+Ostronaut.h"

@implementation UIColor (Ostronaut)
+ (UIColor *)defaultFontColor {
    return RGBCOLOR(93, 93, 93);
}

+ (UIColor *)minorFontColor {
    return RGBCOLOR(182, 182, 182);
}

+ (UIColor *)buttonFontColor {
    return RGBCOLOR(127, 127, 127);
}

+ (UIColor *)backgroundColor {
    return [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
}
@end
