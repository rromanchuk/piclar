
@interface RestPlace : NSObject

@property  NSInteger externalId;
@property (atomic, strong) NSString *title;
@property (atomic, strong) NSString *description;
@property (atomic, strong) NSString *address;
@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSDate *updatedAt;
@property (atomic, strong) NSArray *reviews;

+ (NSDictionary *)mapping;
+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSError *error))onError;

@end
