
/*#import "AFHTTPClient.h"
@protocol NetworkReachabilityDelegate;

@interface RestClient : AFHTTPClient

@property (weak, nonatomic) id <NetworkReachabilityDelegate> delegate;
+ (RestClient *)sharedClient;
+ (NSDictionary *)defaultParameters;
+ (NSDictionary *)defaultParametersWithParams:(NSDictionary *)params;
+ (NSString *)signatureWithMethod:(NSString *)method andParams:(NSMutableDictionary *)params andToken:(NSString *)token;
- (id)initWithBaseURL:(NSURL *)url;

-(NSMutableURLRequest* )signedRequestWithMethod:(NSString *)method
                                           path:(NSString *)path
                                     parameters:(NSDictionary *)parameters;


@end


@protocol NetworkReachabilityDelegate <NSObject>
@required
- (void)networkReachabilityDidChange:(BOOL)connected;

@end
*/