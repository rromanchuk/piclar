#import "RestObject.h"

@interface RestPlace : RestObject
@property double lat;
@property double lon;
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
                 onError:(void (^)(NSError *error))onError;

+ (void)searchByLat:(double)lat
             andLon:(double)lon
                  onLoad:(void (^)(NSSet *places))onLoad
                 onError:(void (^)(NSError *error))onError
           priority:(NSOperationQueuePriority)priority;

+ (void)loadReviewsWithPlaceId:(NSNumber *)placeId
             onLoad:(void (^)(NSSet *reviews))onLoad
            onError:(void (^)(NSError *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestPlace *restPlace))onLoad
       onError:(void (^)(NSError *error))onError;
@end
