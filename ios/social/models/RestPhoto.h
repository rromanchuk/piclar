
@interface RestPhoto : NSObject
@property NSNumber *externalId; 
@property (atomic, strong) NSString *title; 
@property (atomic, strong) NSString *url; 


+ (NSDictionary *)mapping;
@end
