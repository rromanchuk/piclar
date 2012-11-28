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


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"saveOriginal", @"store_orig",
            @"saveFiltered", @"store_filter",
            @"vkShare", @"vk_share",
            nil];
}


+ (void)load:(void (^)(RestUserSettings *restUserSettings))onLoad
     onError:(void (^)(NSError *error))onError {
    
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
                                                                                            
                                                                                            
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

- (void)pushToServer:(void (^)(RestUserSettings *restUserSettings))onLoad
             onError:(void (^)(NSError *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    NSString *path = [USER_SETTINGS_RESOURCE stringByAppendingString:@"/logged/settings.json"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.saveOriginal] , @"store_orig", [NSString stringWithFormat:@"%d", self.saveFiltered] , @"store_filter", [NSString stringWithFormat:@"%d", self.vkShare], @"vk_share", nil];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST"
                                                            path:path
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    
    DLog(@"UserSettings update request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            
                                                                                            RestUserSettings *restUserSettings = [RestUserSettings objectFromJSONObject:JSON mapping:[RestUserSettings mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUserSettings);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                           NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

@end
