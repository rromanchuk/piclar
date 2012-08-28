
#import "AFHTTPClient.h"

@interface RestClient : AFHTTPClient
+ (RestClient *)sharedClient;
+ (NSDictionary *)defaultParameters;
+ (NSDictionary *)defaultParametersWithParams:(NSDictionary *)params;
+ (NSString *)signatureWithMethod:(NSString *)method andParams:(NSMutableDictionary *)params andToken:(NSString *)token;
- (id)initWithBaseURL:(NSURL *)url;

@end
