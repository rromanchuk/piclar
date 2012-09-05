//
//  RestSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/30/12.
//
//

#import "RestSettings.h"
@implementation RestSettings
static NSString *RESOURCE = @"api/v1/settings/";

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"vkScopes", @"vk_scopes",
            @"vkClientId", @"vk_client_id",
            nil];
}


+ (void)loadSettings:(void (^)(RestSettings *))onLoad
             onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@".json"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParameters]];
    
    DLog(@"PLACE IDENTIFER REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON %@", JSON);
                                                                                            
                                                                                            RestSettings *restSettings = [RestSettings objectFromJSONObject:JSON mapping:[RestSettings mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restSettings);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_SETTINGS" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}
@end
