
#import "RestObject.h"
#import "RestUser.h"
#import "RestPlace.h"

@interface RestCheckin : RestObject

@property NSInteger externalId;
@property NSInteger favorites;
@property NSInteger userRating;
@property (atomic, strong) NSString *comment; 
@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) RestUser *user;
@property (atomic, strong) RestPlace *place;
@property (atomic, strong) NSSet *photos;

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
