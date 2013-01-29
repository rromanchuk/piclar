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
@end
