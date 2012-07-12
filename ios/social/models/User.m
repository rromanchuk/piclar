#import "User.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

static User *_currentUser = nil;
static NSString *RESOURCE = @"api/v1/person/";

@implementation User

@synthesize firstName; 
@synthesize lastName;
@synthesize email;
@synthesize userId;
@synthesize token;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
    @"firstName", @"firstname",
    @"lastName", @"lastname",
    @"email", @"email",
    @"userId", @"id",
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
                                                                                            User *user = [User objectFromJSONObject:JSON mapping:[User mapping]];
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
                                                                                            User *user = [User objectFromJSONObject:JSON mapping:[User mapping]];
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
    return self.userId == [User currentUser].userId;
}

+ (void)setCurrentUser:(User *)user
{
    _currentUser = user;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:user.userId forKey:@"currentUser"];
    [defaults synchronize];
}

+ (void)deleteCurrentUser
{
    _currentUser = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"currentUser"];
    [defaults synchronize];
}

+ (User *)currentUser
{
    return _currentUser;
}

+ (int)currentUserId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"currentUser"];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"EMAIL: %@\nFIRSTNAME: %@\nLASTNAME:%@\n",
            self.email, self.firstName, self.lastName];
}

@end
