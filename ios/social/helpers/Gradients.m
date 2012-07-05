//
//  Gradients.m
//  social
//
//  Created by Ryan Romanchuk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Gradients.h"

@implementation Gradients

+ (CAGradientLayer *) defaultGradient {
    UIColor *colorOne = [UIColor colorWithRed:239.0 green:239.0 blue:239.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:249.0 green:249.0 blue:249.0 alpha:1.0];
    //UIColor *colorTwo = [UIColor whiteColor]; 
    
    //UIColor *colorFour = [UIColor whiteColor];
    NSArray *colors = [NSArray arrayWithObjects:colorOne, colorTwo, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    //NSNumber *stopThree = [NSNumber numberWithFloat:0.99];
    //NSNumber *stopFour = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
 
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    return headerLayer;
}

@end
