//
//  RailsRestClient.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 1/29/13.
//
//

#import "AFHTTPClient.h"

@interface RailsRestClient : AFHTTPClient
+ (RailsRestClient *)sharedClient;
- (NSMutableURLRequest *)signedRequestWithMethod:(NSString *)method
                                            path:(NSString *)path
                                      parameters:(NSDictionary *)_params;
@end
