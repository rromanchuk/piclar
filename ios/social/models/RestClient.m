#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "RestClient.h"
#import "Config.h"
#import "AFJSONRequestOperation.h"
#import "RestUser.h"
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
    if ([RestUser currentUser]) {
        NSString *salt = @"***REMOVED***";
        NSString *base = [NSString stringWithFormat:@"%d:%@:%@", [RestUser currentUser].externalId, [RestUser currentUser].token, salt];
        return [Utils MD5:base];
    }
    else {
        return @"";
    }
}

+ (NSMutableDictionary *)defaultParameters
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([RestUser currentUser]) {
        [dict setObject:[NSNumber numberWithInt:[RestUser currentUser].externalId] forKey:@"person_id"];
        //[dict setObject:[self requestSignature]                                forKey:@"request_token"];
    }
    return dict;
}

+ (NSMutableDictionary *)defaultParametersWithParams:(NSDictionary *)params
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self defaultParameters]];
    [dict addEntriesFromDictionary:params];
    return dict;
}

+ (NSString *)signatureWithMethod:(NSString *)method andParams:(NSMutableDictionary *)params andToken:(NSString *)token {
    NSString *salt = @"***REMOVED***";
    NSString *data = [method stringByAppendingString:@" "];
    data = [data stringByAppendingString:[self queryParamsWithDict:params]];
    data = [data stringByAppendingString:@" "];
    data = [data stringByAppendingString:salt];
    NSLog(@"data to be hashed: %@", data);
    const char *cKey  = [token cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
   
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    NSString *hash = [HMAC description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSLog(@"HASH IS %@", hash);
    NSString *signature = [[[RestUser currentUserId] stringValue] stringByAppendingFormat:@":%@", hash];
    NSLog(@"Final signature is %@", signature);
    return signature;
}

+ (NSString *)queryParamsWithDict:(NSMutableDictionary *)dictionary {
    NSString *query = @"";
    for (NSString *key in dictionary) {
        NSString *valueString = [[dictionary objectForKey:key] description];
        NSLog(@"looking up key %@ and value :%@", key, valueString);
        query = [query stringByAppendingFormat:@"%@=%@&", key, valueString];
    }
    query = [query substringToIndex:[query length] - 2];
    NSLog(@"query is %@", query);
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"query is %@", query);
    return query;
}
@end
