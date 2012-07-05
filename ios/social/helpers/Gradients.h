//
//  Gradients.h
//  social
//
//  Created by Ryan Romanchuk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Gradients : NSObject

+ (CAGradientLayer *) defaultGradient;
+ (CAGradientLayer *) greyGradient;
+ (CAGradientLayer *) blueGradient;

@end
