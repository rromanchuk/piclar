//
//  RestReview.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/10/12.
//
//

#import "RestReview.h"
#import "RestPhoto.h"
@implementation RestReview

@synthesize review;
@synthesize createdAt;
@synthesize rating;
@synthesize photos;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"review", @"review",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
            nil];
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestComment] EXTERNAL_ID: %d\nCREATED AT: %@\n REVIEW: %@\n RATING: %d\NPHOTOS: %@\n",
            self.externalId, self.createdAt, self.review, self.rating, self.photos];
}

@end
