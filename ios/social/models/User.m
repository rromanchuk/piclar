#import "User.h"

static User *_currentUser = nil;

@implementation User

@synthesize first_name; 
@synthesize last_name;
@synthesize username;
@synthesize email;
@synthesize identifier;

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
