//
//  RestComment.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestComment.h"

@implementation RestComment
@synthesize comment;
@synthesize createdAt;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"comment", @"comment",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user" mapping:[RestUser mapping]], @"creator",
            nil];
    
}

@end
