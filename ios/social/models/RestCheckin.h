

#import "RestUser.h"
@interface RestCheckin : NSObject

@property NSInteger *externalId;
@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) RestUser *user;

+ (void)loadIndexFromRest:(void (^)(id object))onLoad
                  onError:(void (^)(NSError *error))onError
                 withPage:(int)page;
@end
