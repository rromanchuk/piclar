//
//  RestFeedItem.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestCheckin.h"
#import "RestUser.h"

@interface RestFeedItem : RestObject
@property NSInteger favorites; 
@property (atomic, strong) NSString *type;
@property (atomic, strong) RestCheckin *checkin;
@property (atomic, strong) RestUser *user;
@property (atomic, strong) NSSet *comments; 

@end
