

#import "RestUser.h"
@interface RestCheckin : NSObject

@property (atomic, strong) NSNumber *externalId;
@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) RestUser *user;


+ (NSDictionary *)mapping;
+ (void)loadIndexFromRest:(void (^)(id object))onLoad
                onError:(void (^)(NSString *error))onError
                 withPage:(int)page;
@end
