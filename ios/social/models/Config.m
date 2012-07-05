#import "Config.h"

@implementation Config

@synthesize vkAppId; 
@synthesize vkSecretId; 

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *configuration    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
        NSLog(@"CONFIG: %@", configuration);
        NSBundle *bundle           = [NSBundle mainBundle];
        NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:@"Environments" ofType:@"plist"]];
        NSDictionary *environment  = [environments objectForKey:configuration];
        self.vkAppId        = [environment valueForKey:@"vkAppId"];
        self.vkSecretId      = [environment valueForKey:@"vkSecretId"];
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
