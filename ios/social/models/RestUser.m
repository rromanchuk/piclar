#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"
#import "RestFeedItem.h"

static RestUser *_currentUser = nil;
static NSString *RESOURCE = @"api/v1/person";

@implementation RestUser

@synthesize firstName; 
@synthesize lastName;
@synthesize email;
@synthesize token;
@synthesize vkontakteToken;
@synthesize facebookToken;
@synthesize vkUserId;
@synthesize checkins;
@synthesize remoteProfilePhotoUrl;
@synthesize profilePhoto;
@synthesize followers;
@synthesize following;
@synthesize location;
@synthesize gender;
@synthesize birthday;
@synthesize modifiedDate;
@synthesize registrationStatus;
@synthesize isNewUserCreated;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"firstname",
    @"lastName", @"lastname",
    @"fullName", @"full_name",
    @"location", @"location",
    @"gender", @"sex",
    @"email", @"email",
    @"externalId", @"id",
    @"checkinsCount", @"checkins_count",
    @"token", @"token",
    @"remoteProfilePhotoUrl", @"photo_url",
    @"registrationStatus", @"status",
    @"isNewUserCreated", @"is_new_user_created",
    @"isFollowed", @"is_followed",
    [NSDate mappingWithKey:@"birthday"
            dateFormatString:@"yyyy-MM-dd HH:mm:ss"], @"birthday",
    [NSDate mappingWithKey:@"modifiedDate"
            dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"modified_date",
    nil];
    
}

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestUser *restUser))onLoad
       onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" 
                                                            path:[RESOURCE stringByAppendingString:@".json"] 
                                                      parameters:[RestClient defaultParametersWithParams:parameters]];
    
    
    DLog(@"CREATE REQUEST: %@", request);
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
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"CREATE_USER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
}

#warning rename this, too vague 
+ (void)updateToken:(NSString *)token
             onLoad:(void (^)(RestUser *restUser))onLoad
            onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:token forKey:@"token"];
    [params setValue:@"facebook" forKey:@"provider"];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    

    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST"
                                                            path:[RESOURCE stringByAppendingString:@"/logged/updatesocial.json"]
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
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"UPDATE_USER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"username", password, @"password", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" 
                                                            path:[RESOURCE stringByAppendingString:@"/login.json"] 
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"LOGIN REGUEST is %@", request);
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
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOGIN_USER_WITH_EMAIL" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
}

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSString *))onError {
    RestClient *restClient = [RestClient sharedClient];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:[RESOURCE stringByAppendingFormat:@"/%@.json", identifier] 
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"User load by indentifier error: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];

    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" 
                                                            path:[RESOURCE stringByAppendingString:@"/logged.json"] 
                                                      parameters:[RestClient defaultParametersWithParams:params]];
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
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"RELOAD_USER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loadFollowing:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError {
    
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    

    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@/following.json", externalId]];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:path
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"User following request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            NSMutableSet *users = [[NSMutableSet alloc] init];
                                                                                            for (id userData in JSON) {
                                                                                                RestUser *restUser = [RestUser objectFromJSONObject:userData mapping:[RestUser mapping]];
                                                                                                [users addObject:restUser];
                                                                                            }
                                                                                            if (onLoad)
                                                                                                onLoad(users);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_FOLLOWING" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)loadFollowers:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
            onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    
    
    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@/followers.json", externalId]];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:path
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"User followers request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            NSMutableSet *users = [[NSMutableSet alloc] init];
                                                                                            for (id userData in JSON) {
                                                                                                RestUser *restUser = [RestUser objectFromJSONObject:userData mapping:[RestUser mapping]];
                                                                                                [users addObject:restUser];
                                                                                            }
                                                                                            if (onLoad)
                                                                                                onLoad(users);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_FOLLOWERS" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}


+ (void)loadFeedByIdentifier:(NSNumber *)identifer
                      onLoad:(void (^)(NSSet *restFeedItems))onLoad
                     onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    NSString *path;
    path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%@/feed.json", identifer]];
    
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:path
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"User feed request: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"JSON: %@", JSON);
                                                                                            NSMutableSet *restFeedItems = [[NSMutableSet alloc] init];
                                                                                            for (id feedData in JSON) {
                                                                                                RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedData mapping:[RestFeedItem mapping]];
                                                                                                [restFeedItems addObject:restFeedItem];
                                                                                            }
                                                                                            if (onLoad)
                                                                                                onLoad(restFeedItems);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_FEED" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)followUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
     NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:[RESOURCE stringByAppendingFormat:@"/%@/follow.json", externalId] parameters:[RestClient defaultParametersWithParams:params]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"CHECK_CODE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError) {
                                                                                                
                                                                                                DLog(@"%@", publicMessage);
                                                                                                onError(publicMessage);
                                                                                            }
                                                                                            
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)unfollowUser:(NSNumber *)externalId
              onLoad:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:[RESOURCE stringByAppendingFormat:@"/%@/unfollow.json", externalId] parameters:[RestClient defaultParametersWithParams:params]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"CHECK_CODE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError) {
                                                                                                
                                                                                                DLog(@"%@", publicMessage);
                                                                                                onError(publicMessage);
                                                                                            }
                                                                                            
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}


- (void)checkCode:(NSString*)code
            onLoad:(void (^)(RestUser *restUser))onLoad
            onError:(void (^)(NSString* error))onError {

    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:code, @"code", nil];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:[RESOURCE stringByAppendingString:@"/logged/check_code.json"] parameters:[RestClient defaultParametersWithParams:params]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             RestUser *restUser = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                             if (onLoad)
                                                                                                 onLoad(restUser);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"CHECK_CODE" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError) {
                                                                                                
                                                                                                DLog(@"%@", publicMessage);
                                                                                                onError(publicMessage);
                                                                                            }
                                                                                                
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

    
}

- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError
{
    
    RestClient *restClient = [RestClient sharedClient];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ssZ"];
    NSString *dateString = [format stringFromDate:self.birthday];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.firstName, @"firstname", self.lastName, @"lastname", self.email, @"email", self.location, @"location", dateString, @"birthday", nil];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST"
                                                            path:[RESOURCE stringByAppendingString:@"/logged/update.json"]
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
                                                                                             NSString *publicMessage = [RestObject processError:error for:@"UPDATE_USER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)setCurrentUser:(RestUser *)user
{
    _currentUser = user;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:user.externalId forKey:@"currentUser"];
    [defaults setObject:[NSNumber numberWithInteger:user.externalId ] forKey:@"currentUserId"];
    if (user.token) {
        [defaults setObject:user.token forKey:@"userAuthenticationToken"];
    }
    [defaults synchronize];
}

+ (void)deleteCurrentUser
{
    _currentUser = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userAuthenticationToken"];
    [defaults removeObjectForKey:@"currentUser"];
    [defaults removeObjectForKey:@"currentUserId"];
    [defaults synchronize];
}

+ (RestUser *)currentUser
{
    return _currentUser;
}


+ (NSNumber *)currentUserId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"currentUserId"];
}

+ (NSString *)currentUserToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userAuthenticationToken"];
}



- (NSString *) description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId", self.email, @"email", self.firstName, @"firstName", self.lastName, @"lastName", self.checkins, @"checkins", self.vkontakteToken, @"vkontakteToken", nil];
    return [dict description];
}

@end
