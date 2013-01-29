//
//  RailsRestClient.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 1/29/13.
//
//

#import "RailsRestClient.h"
#import "Config.h"

@implementation RailsRestClient

+ (RailsRestClient *)sharedClient
{
    static dispatch_once_t pred;
    static RailsRestClient *_sharedClient;
    
    dispatch_once(&pred, ^{
        _sharedClient = [[RailsRestClient alloc] initWithBaseURL:[NSURL URLWithString:[Config sharedConfig].baseURL]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    
    if (self) {
        [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
//        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            [self.delegate networkReachabilityDidChange:status];
//        }];
        
    }
    
    return self;
}


@end
