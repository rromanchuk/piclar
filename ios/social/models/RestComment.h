//
//  RestComment.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestObject.h"
@interface RestComment : RestObject
@property (atomic, strong) NSString *comment;
@property (atomic, strong) NSDate *createdAt;
+ (NSDictionary *)mapping;
@end
