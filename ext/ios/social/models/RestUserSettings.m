//
//  RestUserSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "RestUserSettings.h"
#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "RailsRestClient.h"

static NSString *USER_SETTINGS_RESOURCE = @"users";

@implementation RestUserSettings


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"saveOriginal", @"save_original",
            @"saveFiltered", @"save_filtered",
            @"pushPosts", @"push_posts",
            @"pushLikes", @"push_likes",
            @"pushFriends", @"push_friends",
            @"pushComments", @"push_comments",
            nil];
}


+ (void)load:(void (^)(RestUserSettings *restUserSettings))onLoad
     onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSString *path = [USER_SETTINGS_RESOURCE stringByAppendingString:@"/settings.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
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
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    NSString *path = [USER_SETTINGS_RESOURCE stringByAppendingString:@"/update_settings.json"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.saveOriginal], @"user[save_original]",
                                   [NSString stringWithFormat:@"%d", self.saveFiltered] , @"user[save_filtered]",
                                   [NSString stringWithFormat:@"%d", self.pushComments], @"user[push_comments]",
                                   [NSString stringWithFormat:@"%d", self.pushFriends], @"user[push_friends]",
                                   [NSString stringWithFormat:@"%d", self.pushLikes], @"user[push_likes]",
                                   [NSString stringWithFormat:@"%d", self.pushPosts], @"user[push_posts]", nil];
    
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"PUT"
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
