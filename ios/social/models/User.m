#import "User.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

static User *_currentUser = nil;
static NSString *RESOURCE = @"person";
@implementation User

@synthesize first_name; 
@synthesize last_name;
@synthesize username;
@synthesize email;
@synthesize identifier;
@synthesize token;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(id object))onLoad
       onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:RESOURCE parameters:[RestClient defaultParameters]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Name: %@ %@", [JSON valueForKeyPath:@"first_name"], [JSON valueForKeyPath:@"last_name"]);
    } failure:nil];
    
    [operation start];
}

- (BOOL)isCurrentUser
{
    return self.identifier == [User currentUser].identifier;
}

+ (void)setCurrentUser:(User *)user
{
    _currentUser = user;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:user.identifier forKey:@"currentUser"];
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


@end
