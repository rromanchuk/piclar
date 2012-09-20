#import "Config.h"
#import "RestSettings.h"
#import "Settings+Rest.h"
@implementation Config

@synthesize vkAppId; 
@synthesize vkSecretId; 
@synthesize vkPermissions;
@synthesize vkRedirectUrl;
@synthesize baseURL; 
@synthesize secureBaseURL;
@synthesize apiVersion; 
@synthesize vkUrl;
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *configuration    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
        NSBundle *bundle           = [NSBundle mainBundle];
        NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:@"environments" ofType:@"plist"]];
        NSDictionary *environment  = [environments objectForKey:configuration];
        self.vkAppId = [environment valueForKey:@"vkAppId"];
        self.vkSecretId = [environment valueForKey:@"vkSecretId"];
        self.vkPermissions = [environment valueForKey:@"vkPermissions"];
        self.vkRedirectUrl = [environment valueForKey:@"vkRedirectUrl"];
        self.baseURL = [environment valueForKey:@"baseURL"];
        self.secureBaseURL = [environment valueForKey:@"secureBaseURL"];
        self.apiVersion = [environment valueForKey:@"apiVersion"];
        self.vkUrl = [environment valueForKey:@"vkUrl"];
    }
    
    return self;
}

- (void)updateWithServerSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.vkPermissions = [defaults objectForKey:@"vkScopes"];
    self.vkAppId =  [defaults objectForKey:@"vkClientId"];
    self.vkUrl =  [defaults objectForKey:@"vkUrl"];
    DLog(@"updating settings with %@ and %@", self.vkAppId, self.vkPermissions);
}

+ (Config *)sharedConfig
{
    static dispatch_once_t pred;
    static Config *sharedConfig;
    
    dispatch_once(&pred, ^{
        sharedConfig = [[Config alloc] init];
    });
    
    return sharedConfig;
}

@end
