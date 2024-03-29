#import "Config.h"
#import "RestSettings.h"

@implementation Config

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *configuration    = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
        NSBundle *bundle           = [NSBundle mainBundle];
        NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:[bundle pathForResource:@"environments" ofType:@"plist"]];
        NSDictionary *environment  = [environments objectForKey:configuration];
        self.vkAppId = [environment valueForKey:@"vkAppId"];
        self.fbAppId = [environment valueForKey:@"fbAppId"];
        self.vkSecretId = [environment valueForKey:@"vkSecretId"];
        self.vkPermissions = [environment valueForKey:@"vkPermissions"];
        self.vkRedirectUrl = [environment valueForKey:@"vkRedirectUrl"];
        self.baseURL = [environment valueForKey:@"baseURL"];
        self.secureBaseURL = [environment valueForKey:@"secureBaseURL"];
        self.apiVersion = [environment valueForKey:@"apiVersion"];
        self.vkUrl = [environment valueForKey:@"vkUrl"];
        self.railsBaseURL = [environment valueForKey:@"railsBaseURL"];
        
        self.airshipSecretProd = [environment valueForKey:@"PRODUCTION_APP_SECRET"];
        self.airshipKeyProd = [environment valueForKey:@"PRODUCTION_APP_KEY"];
        
        
        self.airshipSecretDev = [environment valueForKey:@"DEVELOPMENT_APP_SECRET"];
        self.airshipKeyDev = [environment valueForKey:@"DEVELOPMENT_APP_KEY"];
        self.adHoc = [environment valueForKey:@"APP_STORE_OR_AD_HOC_BUILD"];
        [self updateWithServerSettings];
    }
    
    return self;
}

- (void)updateWithServerSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"vkScopes"])
        self.vkPermissions = [defaults objectForKey:@"vkScopes"];
    if ([defaults objectForKey:@"vkClientId"])
        self.vkAppId =  [defaults objectForKey:@"vkClientId"];
    if ([defaults objectForKey:@"vkUrl"]) {
        DLog(@"from defaults %@", [defaults objectForKey:@"vkUrl"]);
        self.vkUrl = [defaults objectForKey:@"vkUrl"];
    }
    
    DLog(@"updating settings with %@ and %@ and %@", self.vkAppId, self.vkPermissions, self.vkUrl);
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
