//
//  RestCheckin.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestUser.h"
@interface RestCheckin : NSObject

@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) RestUser *user;

+ (void)loadIndexFromRest:(void (^)(id object))onLoad
                  onError:(void (^)(NSError *error))onError
                 withPage:(int)page;
@end
