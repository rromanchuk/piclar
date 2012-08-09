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

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestComment] EXTERNAL_ID: %d\nCREATED AT: %@\n COMMENT: %@\nUSER: %@\n",
            self.externalId, self.createdAt, self.comment, self.user];
}

@end
