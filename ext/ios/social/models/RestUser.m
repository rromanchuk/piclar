#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "RestFeedItem.h"
#import "RailsRestClient.h"
static NSString *RAILS_AUTH = @"token_authentications.json";
static NSString *RAILS_RESOURCE = @"users";
static NSString *RELATIONSHIP_RESOURCE = @"relationships";

@implementation RestUser


+ (NSDictionary *)mapping {
    return [self mapping:NO];
}


+ (NSDictionary *)mapping:(BOOL)is_nested {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"first_name",
    @"lastName", @"last_name",
    //@"fullName", @"full_name",
    @"location", @"location",
    @"gender", @"sex",
    @"email", @"email",
    @"externalId", @"id",
    //@"checkinsCount", @"checkins_count",
    @"authenticationToken", @"authentication_token",
    @"fbToken", @"fb_token",
    //@"vkToken", @"vk_token"
    @"remoteProfilePhotoUrl", @"photo_url",
    //@"registrationStatus", @"status",
    //@"isNewUserCreated", @"is_new_user_created",
    @"isFollowed", @"is_followed",
    [NSDate mappingWithKey:@"birthday"
            dateFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"], @"birthday",
    [NSDate mappingWithKey:@"modifiedDate"
            dateFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"], @"updated_at",
    nil];
    if (!is_nested) {
        [map setObject:[RestUser mappingWithKey:@"followers" mapping:[RestUser mapping:YES]] forKey:@"followers"];
        [map setObject:[RestUser mappingWithKey:@"following" mapping:[RestUser mapping:YES]] forKey:@"following"];

    }
    return map;
    
}

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestUser *restUser))onLoad
       onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *railsClient = [RailsRestClient sharedClient];
    
    NSMutableURLRequest *request = [railsClient requestWithMethod:@"POST"
                                                            path:RAILS_AUTH
                                                      parameters:[RestClient defaultParametersWithParams:parameters]];
    
    ALog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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

+ (void)updateProviderToken:(NSString *)token
                forProvider:(NSString *)provider
             onLoad:(void (^)(RestUser *restUser))onLoad
            onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
   
    
    NSDictionary *params;
    if ([provider isEqualToString:@"facebook"]) {
        params = @{@"user[fb_token]": token};
    } else {
        params = @{@"user[vk_token": token};
    }
    
       
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"PUT"
                                                            path:[RAILS_RESOURCE stringByAppendingString:@"/update_settings.json"]
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    
    DLog(@"User update token request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"ERROR %@", response);
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}


+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSError *))onError {
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSMutableURLRequest *request = [restClient  signedRequestWithMethod:@"GET"
                                                            path:[RAILS_RESOURCE stringByAppendingFormat:@"/%@.json", identifier]
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    
    DLog(@"USER BY IDENTIFIER REQUEST is %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            DLog(@"error %@", customError);
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSError *error))onError {
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET"
                                                            path:[RAILS_RESOURCE stringByAppendingString:@"/me.json"]
                                                      parameters:params];
    DLog(@"USER RELOAD REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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

+ (void)loadFollowingInfo:(NSNumber *)externalId
               onLoad:(void (^)(RestUser *user))onLoad
              onError:(void (^)(NSError *error))onError {
    
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *path = [RAILS_RESOURCE stringByAppendingString:@"/following_followers.json"];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET"
                                                            path:path
                                                      parameters:params];
    DLog(@"User following request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                // Add code here to update the UI/send notifications based on the
                                                                                                // results of the background processing
                                                                                                    if (onLoad)
                                                                                                        onLoad(user);
                                                                                                });
                                                                                            });
                                                                                            
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

+ (void)loadSuggested:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];    
    NSString *path = [RAILS_RESOURCE stringByAppendingString:@"/suggested.json"];
    
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET"
                                                            path:path
                                                      parameters:params];
    DLog(@"User suggested request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                NSMutableSet *users = [[NSMutableSet alloc] init];
                                                                                                for (id userData in JSON) {
                                                                                                    RestUser *restUser = [RestUser objectFromJSONObject:userData mapping:[RestUser mapping]];
                                                                                                    [users addObject:restUser];
                                                                                                }
                                                                                                
                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                // Add code here to update the UI/send notifications based on the
                                                                                                // results of the background processing
                                                                                                    if (onLoad)
                                                                                                        onLoad(users);
                                                                                                });
                                                                                            });
                                                                                            
                                                                                            
                                                                                            
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


+ (void)loadFeedByIdentifier:(NSNumber *)identifer
                      onLoad:(void (^)(NSSet *restFeedItems))onLoad
                     onError:(void (^)(NSError *error))onError {
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
    NSString *path = [RAILS_RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@/feed.json", identifer]];
    
    
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET"
                                                            path:path
                                                      parameters:params];
    ALog(@"User feed request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                NSMutableSet *restFeedItems = [[NSMutableSet alloc] init];
                                                                                                for (id feedData in JSON) {
                                                                                                    RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedData mapping:[RestFeedItem mapping]];
                                                                                                    [restFeedItems addObject:restFeedItem];
                                                                                                }
                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                    if (onLoad)
                                                                                                        onLoad(restFeedItems);
                                                                                                });
                                                                                            });
                                                                                            
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

+ (void)followUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSError *error))onError {
    //RestClient *restClient = [RestClient sharedClient];
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSDictionary *params = @{@"relationship[followed_id]": externalId};
    NSMutableURLRequest *request = [railsRestClient requestWithMethod:@"POST" path:[RELATIONSHIP_RESOURCE stringByAppendingFormat:@".json"] parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError) {
                                                                                                DLog(@"%@", customError);
                                                                                                onError(customError);
                                                                                            }
                                                                                            
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)unfollowUser:(NSNumber *)externalId
              onLoad:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSError *error))onError {
//    RestClient *restClient = [RestClient sharedClient];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
//    [params setValue:signature forKey:@"auth"];
//    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:[RESOURCE stringByAppendingFormat:@"/%@/unfollow.json", externalId] parameters:[RestClient defaultParametersWithParams:params]];
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request = [railsRestClient requestWithMethod:@"DELETE" path:[RELATIONSHIP_RESOURCE stringByAppendingFormat:@"/%@.json", externalId] parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError) {
                                                                                                DLog(@"%@", customError);
                                                                                                onError(customError);
                                                                                            }
                                                                                            
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}


- (void)checkCode:(NSString*)code
            onLoad:(void (^)(RestUser *restUser))onLoad
            onError:(void (^)(NSError *error))onError {

    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", nil];
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"POST" path:[RAILS_RESOURCE stringByAppendingString:@"/check_code.json"] parameters:[RestClient defaultParametersWithParams:params]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                             if (onLoad)
                                                                                                 onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError) {
                                                                                                
                                                                                                DLog(@"%@", customError);
                                                                                                onError(customError);
                                                                                            }
                                                                                                
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}

- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSError *error))onError
{
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString *dateString = [format stringFromDate:self.birthday];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.firstName, @"user[first_name]", self.lastName, @"user[last_name]", self.email, @"user[email]", self.location, @"user[location]", dateString, @"user[birthday]", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"PUT"
                                                            path:[RAILS_RESOURCE stringByAppendingString:@"/update_user.json"]
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    
    
    
    DLog(@"User update request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
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

+ (void)resetIdentifiers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userAuthenticationToken"];
    [defaults removeObjectForKey:@"currentUser"];
    [defaults removeObjectForKey:@"currentUserId"];
    [defaults synchronize];
}

+ (void)setCurrentUserId:(NSInteger)externalId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:externalId] forKey:@"currentUserId"];
    [defaults synchronize];
}

+ (NSNumber *)currentUserId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"currentUserId"];
}

+ (void)setCurrentUserToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"userAuthenticationToken"];
    [defaults synchronize];
}

+ (NSString *)currentUserToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userAuthenticationToken"];
}

//- (NSString *) description {
//    NSDictionary *dict =  @{@"externalId" : [NSNumber numberWithInteger:self.externalId], @"email" : self.email, @"firstName": self.firstName, @"lastName" : self.lastName, @"checkins" : self.checkins, @"vkToken" : self.vkToken };
//    return [dict description];
//}

@end
