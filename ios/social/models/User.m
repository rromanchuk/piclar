#import "User.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

static User *_currentUser = nil;
static NSString *RESOURCE = @"api/v1/person/?format=json";
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
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:RESOURCE parameters:parameters];
    NSLog(@"Request is %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"firstname"], [JSON valueForKeyPath:@"lastname"]);
                                                                                            User *user = [User objectFromJSONObject:JSON mapping:[User mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(user);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"There was a problem with the request");
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
