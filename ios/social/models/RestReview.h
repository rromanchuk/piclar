//
//  RestReview.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/10/12.
//
//

#import "RestObject.h"

@interface RestReview : RestObject
@property NSInteger rating;
@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSString *review;
@property (atomic, strong) NSSet *photos;

+ (NSDictionary *)mapping;
@end
