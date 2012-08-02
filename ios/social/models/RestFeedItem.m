//
//  RestFeedItem.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestFeedItem.h"

@implementation RestFeedItem
@synthesize favorites; 
@synthesize type; 
@synthesize checkin; 
@synthesize user;
@synthesize comments;


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"type", @"type",
            [RestUser mappingWithKey:@"user"
                             mapping:[RestUser mapping]], @"creator",
            [RestCheckin mappingWithKey:@"data.checkin" mapping:[RestCheckin mapping]], @"checkin",
            nil];
}

@end
