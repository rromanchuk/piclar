#import <CommonCrypto/CommonDigest.h>
#import "RestClient.h"
#import "Config.h"
#import "AFJSONRequestOperation.h"
#import "User.h"
#import "Utils.h"

@implementation RestClient
+ (RestClient *)sharedClient
{
    static RestClient *_sharedClient = nil;
    NSLog(@"baseURL: %@", [Config sharedConfig].baseURL);
    if (_sharedClient == nil) {
        _sharedClient = (RestClient *)[RestClient clientWithBaseURL:[NSURL URLWithString:[Config sharedConfig].baseURL]];
        [_sharedClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [_sharedClient setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return _sharedClient;
}

+ (NSString *)requestSignature
{
    if ([User currentUser]) {
        NSString *salt = @"b3KcekbJAWp5r0ux";
        NSString *base = [NSString stringWithFormat:@"%d:%@:%@", [User currentUser].userId, [User currentUser].token, salt];
        return [Utils MD5:base];
    }
    else {
        return @"";
    }
}

+ (NSMutableDictionary *)defaultParameters
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([User currentUser]) {
        [dict setObject:[NSNumber numberWithInt:[User currentUser].userId] forKey:@"user_id"];
        [dict setObject:[self requestSignature]                                forKey:@"request_token"];
    }
    return dict;
}

+ (NSMutableDictionary *)defaultParametersWithParams:(NSDictionary *)params
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self defaultParameters]];
    [dict addEntriesFromDictionary:params];
    return dict;
}
@end