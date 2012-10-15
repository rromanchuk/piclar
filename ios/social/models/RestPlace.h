#import "RestObject.h"

@interface RestPlace : RestObject
@property float lat;
@property float lon;
@property NSInteger typeId;
@property NSInteger rating;
@property (atomic, strong) NSString *title;
@property (atomic, strong) NSString *desc;
@property (atomic, strong) NSString *address;
@property (atomic, strong) NSString *type;
@property (atomic, strong) NSString *cityName;
@property (atomic, strong) NSString *countryName;

@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) NSSet *photos;
@property (atomic, strong) NSSet *checkins;


+ (NSDictionary *)mapping;
+ (NSDictionary *)mapping:(BOOL)is_nested;
+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestPlace *restPlace))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)searchByLat:(float)lat
             andLon:(float)lon
                  onLoad:(void (^)(NSSet *places))onLoad
                 onError:(void (^)(NSString *error))onError
           priority:(NSOperationQueuePriority)priority;

+ (void)loadReviewsWithPlaceId:(NSNumber *)placeId
             onLoad:(void (^)(NSSet *reviews))onLoad
            onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestPlace *restPlace))onLoad
       onError:(void (^)(NSString *error))onError;
@end
