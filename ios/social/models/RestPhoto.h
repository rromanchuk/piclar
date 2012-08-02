#import "RestObject.h"

@interface RestPhoto : RestObject
@property (atomic, strong) NSString *title; 
@property (atomic, strong) NSString *url; 


+ (NSDictionary *)mapping;
@end
