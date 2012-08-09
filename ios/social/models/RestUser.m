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

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"firstname",
    @"lastName", @"lastname",
    @"fullName", @"full_name",
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
    NSLog(@"CREATE REQUEST: %@", request);
    TFLog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"username", password, @"password", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" 
                                                            path:[RESOURCE stringByAppendingString:@"/login.json"] 
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"LOGIN REGUEST is %@", request);
    TFLog(@"LOGIN REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSString *))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" 
                                                            path:[RESOURCE stringByAppendingFormat:@"/%@.json", identifier] 
                                                      parameters:[RestClient defaultParameters]];
    NSLog(@"USER BY IDENTIFIER REQUEST is %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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

+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSLog(@"Before signature generation");
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    NSLog(@"After signature generation");

    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" 
                                                            path:[RESOURCE stringByAppendingString:@"/logged.json"] 
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"USER RELOAD REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            RestUser *user = [RestUser objectFromJSONObject:JSON mapping:[RestUser mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
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
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nEMAIL: %@\nFIRSTNAME: %@\nLASTNAME:%@\nCHECKINS: @%\nVKONTAKTE_TOKEN: %@",
            self.externalId, self.email, self.firstName, self.lastName, self.checkins, self.vkontakteToken];
}

@end
