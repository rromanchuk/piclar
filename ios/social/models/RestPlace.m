//
//  RestPlace.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestPlace.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

@implementation RestPlace

static NSString *RESOURCE = @"api/v1/place/";
@synthesize title; 
@synthesize description;
@synthesize address;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize reviews;
@synthesize externalId;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"title", @"title",
            @"description", @"description",
            @"address", @"address",
            @"externalId", @"id",
            nil];
}

+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSError *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@"1"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParameters]];
    NSLog(@"Request is %@", request);
    TFLog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
                                                                                            RestPlace *place = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(place);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

@end
