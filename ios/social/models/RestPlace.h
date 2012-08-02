#import "RestObject.h"

@interface RestPlace : RestObject

@property (atomic, strong) NSString *title;
@property (atomic, strong) NSString *desc;
@property (atomic, strong) NSString *address;
@property (atomic, strong) NSString *type;
@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) NSArray *reviews;
@property (atomic, strong) NSArray *photos;

+ (NSDictionary *)mapping;
+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad 
                 onError:(void (^)(NSString *error))onError;

+ (void)searchByLat:(float)lat
             andLon:(float)lon
                  onLoad:(void (^)(id object))onLoad 
                 onError:(void (^)(NSString *error))onError;

@end
