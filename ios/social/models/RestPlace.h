#import "RestObject.h"

@interface RestPlace : RestObject
@property float lat;
@property float lon;
@property NSInteger rating;
@property (atomic, strong) NSString *title;
@property (atomic, strong) NSString *desc;
@property (atomic, strong) NSString *address;
@property (atomic, strong) NSString *type;
@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) NSSet *photos;
@property (atomic, strong) NSSet *checkins;

+ (NSDictionary *)mapping;
+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad 
                 onError:(void (^)(NSString *error))onError;

+ (void)searchByLat:(float)lat
             andLon:(float)lon
                  onLoad:(void (^)(NSSet *places))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)loadReviewsWithPlaceId:(NSNumber *)placeId
             onLoad:(void (^)(NSSet *reviews))onLoad
            onError:(void (^)(NSString *error))onError;

@end
