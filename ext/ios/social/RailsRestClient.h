//
//  RailsRestClient.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 1/29/13.
//
//

#import "AFHTTPClient.h"
@protocol NetworkReachabilityDelegate;

@interface RailsRestClient : AFHTTPClient
@property (weak, nonatomic) id <NetworkReachabilityDelegate> delegate;

+ (RailsRestClient *)sharedClient;
- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method
                                            path:(NSString *)path
                                      parameters:(NSDictionary *)_params;
@end

@protocol NetworkReachabilityDelegate <NSObject>
@required
- (void)networkReachabilityDidChange:(BOOL)connected;

@end