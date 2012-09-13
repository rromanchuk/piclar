//
//  RestUserSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "RestUserSettings.h"
#import "RestClient.h"
#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

static NSString *USER_SETTINGS_RESOURCE = @"api/v1/person";

@implementation RestUserSettings
@synthesize vkShare;
@synthesize saveFiltered;
@synthesize saveOriginal;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"saveOriginal", @"SETTINGS_STORE_ORIGINAL",
            @"saveFiltered", @"SETTINGS_STORE_FILTERED",
            @"vkShare", @"SETTINGS_VK_SHARE",
            nil];
}


+ (void)load:(void (^)(RestUserSettings *restUserSettings))onLoad
     onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [USER_SETTINGS_RESOURCE stringByAppendingString:@"/logged/settings.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"User settings request %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"Feed item json %@", JSON);
                                                                                            RestUserSettings *restUserSettings = [RestUserSettings objectFromJSONObject:JSON mapping:[RestUserSettings mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUserSettings);
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_SETTINGS" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

@end
