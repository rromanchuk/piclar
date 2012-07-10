#import "Config.h"

@implementation Config

@synthesize vkAppId; 
@synthesize vkSecretId; 
@synthesize vkPermissions;
@synthesize baseURL; 
@synthesize secureBaseURL;
@synthesize apiVersion; 

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *configuration    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
        NSLog(@"CONFIG: %@", configuration);
        NSBundle *bundle           = [NSBundle mainBundle];
        NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:@"Environments" ofType:@"plist"]];
        NSDictionary *environment  = [environments objectForKey:configuration];
        self.vkAppId = [environment valueForKey:@"vkAppId"];
        self.vkSecretId = [environment valueForKey:@"vkSecretId"];
        self.vkPermissions = [environment valueForKey:@"vkPermissions"];
        self.vkRedirectUrl = [environment valueForKey:@"vkRedirectUrl"];
        self.baseURL = [environment valueForKey:@"baseURL"];
        self.secureBaseURL = [environment valueForKey:@"secureBaseURL"];
        self.apiVersion = [environment valueForKey:@"apiVersion"];
    }
    
    return self;
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
