#import "RestUser.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

static RestUser *_currentUser = nil;
static NSString *RESOURCE = @"api/v1/person/";

@implementation RestUser

@synthesize firstName; 
@synthesize lastName;
@synthesize email;
@synthesize token;
@synthesize checkins;
@synthesize externalId;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"firstname",
    @"lastName", @"lastname",
    @"email", @"email",
    @"externalId", @"id",
    nil];
}

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(id object))onLoad
       onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:RESOURCE parameters:[RestClient defaultParametersWithParams:parameters]];
    NSLog(@"Request is %@", request);
    TFLog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"login", password, @"password", nil];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" 
                                                            path:[RESOURCE stringByAppendingString:@"login/"] 
                                                      parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"Request is %@", request);
    TFLog(@"LOGIN REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
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
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" 
                                                            path:[RESOURCE stringByAppendingFormat:@"%@/", identifier] 
                                                      parameters:[RestClient defaultParameters]];
    NSLog(@"Request is %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
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
    [defaults synchronize];
}

+ (void)deleteCurrentUser
{
    _currentUser = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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

- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nEMAIL: %@\nFIRSTNAME: %@\nLASTNAME:%@\nCHECKINS: @%",
            self.externalId, self.email, self.firstName, self.lastName, self.checkins];
}

@end
