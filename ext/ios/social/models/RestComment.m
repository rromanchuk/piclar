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
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user" mapping:[RestUser mapping]], @"user",
            nil];
    
}

- (NSString *) description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId",  self.createdAt, @"createdAt", self.comment, @"comment", self.user, @"user", nil];
    return [dict description];
}

@end
