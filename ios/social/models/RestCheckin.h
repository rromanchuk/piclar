
#import "RestObject.h"
#import "RestUser.h"
@interface RestCheckin : RestObject

@property NSInteger externalId;
@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) RestUser *user;


+ (NSDictionary *)mapping;

+ (void)loadIndex:(void (^)(id object))onLoad
                onError:(void (^)(NSString *error))onError
                 withPage:(int)page;

+ (void)loadByIdentifer:(NSNumber *)identifier
                       onLoad:(void (^)(RestCheckin *checkin))onLoad
                      onError:(void (^)(NSString *error))onError;
            
+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                        onLoad:(void (^)(RestCheckin *checkin))onLoad
                       onError:(void (^)(NSString *error))onError;


@end
