
#import "AFHTTPClient.h"

@interface RestClient : AFHTTPClient
+ (RestClient *)sharedClient;
+ (NSDictionary *)defaultParameters;
+ (NSDictionary *)defaultParametersWithParams:(NSDictionary *)params;
@end
