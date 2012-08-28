#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

static RestUser *_currentUser = nil;
static NSString *RESOURCE = @"api/v1/person";

@implementation RestUser

@synthesize firstName; 
@synthesize lastName;
@synthesize email;
@synthesize token;
@synthesize vkontakteToken;
@synthesize vkUserId;
@synthesize checkins;
@synthesize remoteProfilePhotoUrl;
@synthesize profilePhoto;
@synthesize followers;
@synthesize following;
@synthesize location;
@synthesize gender;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"firstname",
    @"lastName", @"lastname",
    @"fullName", @"full_name",
    @"location", @"location",
    @"gender", @"sex",
    @"email", @"email",
    @"externalId", @"id",
    @"token", @"token",
    @"remoteProfilePhotoUrl", @"photo_url",
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Create user error: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Search places error: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
}

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSString *))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" 
                                                            path:[RESOURCE stringByAppendingFormat:@"/%@.json", identifier] 
                                                      parameters:[RestClient defaultParameters]];
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Reload user errror: %@", message);
                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loadFollowers:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:[RESOURCE stringByAppendingString:@"/logged/followers.json"]
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Load followers error: %@", message);                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)loadFollowing:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET"
                                                            path:[RESOURCE stringByAppendingString:@"/logged/following.json"]
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Load following error: %@", message);                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}

- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError
{
    
    RestClient *restClient = [RestClient sharedClient];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.firstName, @"firstname", self.lastName, @"lastname", self.email, @"email", self.location, @"location", @"", @"birthday", nil];
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
                                                                                            NSString *message = [JSON objectForKey:@"message"];
                                                                                            DLog(@"Load following error: %@", message);                                                                                            if (onError)
                                                                                                onError(message);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

- (BOOL)isCurrentUser
{
    return self.externalId == [RestUser currentUser].externalId;
}

+ (void)setCurrentUser:(RestUser *)user
{
    _currentUser = user;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:user.externalId forKey:@"currentUser"];
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
    [defaults synchronize];
}

+ (RestUser *)currentUser
{
    return _currentUser;
}


+ (NSNumber *)currentUserId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"currentUser"];
}

+ (NSString *)currentUserToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userAuthenticationToken"];
}



- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nEMAIL: %@\nFIRSTNAME: %@\nLASTNAME:%@\nCHECKINS: %@\nVKONTAKTE_TOKEN: %@",
            self.externalId, self.email, self.firstName, self.lastName, self.checkins, self.vkontakteToken];
}

@end
