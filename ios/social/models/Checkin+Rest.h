//
//  Checkin+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Checkin.h"

@interface Checkin (Rest)

+ (void)loadIndexFromRest:(void (^)(id object))onLoad
          onError:(void (^)(NSError *error))onError
         withPage:(int)page;

@end
