//#import <CommonCrypto/CommonDigest.h>
//#import <CommonCrypto/CommonHMAC.h>
//
//#import "RestClient.h"
//#import "Config.h"
//#import "AFJSONRequestOperation.h"
//#import "RestUser.h"
//#import "Utils.h"
//#import "NSString+URLEncode.h"
//
//
//@implementation RestClient
//
//+ (RestClient *)sharedClient
//{
//    static dispatch_once_t pred;
//    static RestClient *_sharedClient;
//    
//    dispatch_once(&pred, ^{
//        _sharedClient = [[RestClient alloc] initWithBaseURL:[NSURL URLWithString:[Config sharedConfig].baseURL]];
//    });
//    
//    return _sharedClient;
//}
//
//- (id)initWithBaseURL:(NSURL *)url {
//    self = [super initWithBaseURL:url];
//    
//    
//    if (self) {
//        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
//        [self setDefaultHeader:@"Accept" value:@"application/json"];
//        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            [self.delegate networkReachabilityDidChange:status];
//        }];
//        
//    }
//    
//    return self;
//}
//
//
//
//
//
//+ (NSMutableDictionary *)defaultParameters
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    return dict;
//}
//
//+ (NSMutableDictionary *)defaultParametersWithParams:(NSDictionary *)params
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self defaultParameters]];
//    [dict addEntriesFromDictionary:params];
//    return dict;
//}
//
//+ (NSString *)signatureWithMethod:(NSString *)method andParams:(NSMutableDictionary *)params andToken:(NSString *)token {
//    NSString *salt = @"";
//    NSString *data = [method stringByAppendingString:@" "];
//    if ([params count] > 0) {
//        data = [data stringByAppendingString:[self queryParamsWithDict:params]];
//    } else {
//        data = [data stringByAppendingString:@""];
//    }
//    
//    data = [data stringByAppendingString:@" "];
//    data = [data stringByAppendingString:salt];
//    DLog(@"data to be hashed: %@", data);
//    const char *cKey  = [token cStringUsingEncoding:NSASCIIStringEncoding];
//    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
//    
//    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//   
//    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
//    
//    NSData *HMAC = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
//    DLog(@"HMAC %@", HMAC);
//    NSString *hash = [HMAC description];
//    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
//    DLog(@"HASH IS %@", hash);
//    NSString *signature = [[[RestUser currentUserId] stringValue] stringByAppendingFormat:@":%@", hash];
//    DLog(@"Final signature is %@", signature);
//    return signature;
//}
//
//- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method
//                                         path:(NSString *)path
//                                   parameters:(NSDictionary *)_params {
//    
//
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//    if (_params != nil) {
//        [parameters addEntriesFromDictionary:_params];
//    }
//
//    
//    NSString *signature = [RestClient signatureWithMethod:method andParams:parameters andToken:[RestUser currentUserToken]];
//    [parameters setValue:signature forKey:@"auth"];
//    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:[RestClient defaultParametersWithParams:parameters]];
//    return request;
//    
//}
//
//+ (NSString *)queryParamsWithDict:(NSMutableDictionary *)dictionary {
//    NSString *query = @"";
//    for (NSString *key in [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)])
//    {
//        NSString *valueString = [[dictionary objectForKey:key] description];
//        DLog(@"looking up key %@ and value :%@", key, valueString);
//        query = [query stringByAppendingFormat:@"%@=%@&", key, [valueString URLEncodedString_ch]];
//    }
//    
//    query = [query substringToIndex:[query length] - 1];
//    DLog(@"query is %@", query);
//    //query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    //query = [query URLEncodedString_ch];
//    DLog(@"query is %@", query);
//    return query;
//}
//
//@end
