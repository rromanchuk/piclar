
@interface Config : NSObject

@property (nonatomic, strong) NSString *vkAppId;
@property (nonatomic, strong) NSString *vkSecretId;
@property (nonatomic, strong) NSString *vkPermissions;
@property (nonatomic, strong) NSString *vkUrl;

@property (nonatomic, strong) NSString *fbAppId;

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *railsBaseURL;

@property (nonatomic, strong) NSString *secureBaseURL;
@property (nonatomic, strong) NSString *apiVersion;
@property (nonatomic, strong) NSString *vkRedirectUrl;
@property (nonatomic, strong) NSString *devicePlatform;

@property (nonatomic, strong) NSString *airshipKeyDev;
@property (nonatomic, strong) NSString *airshipSecretDev;
@property (nonatomic, strong) NSString *airshipKeyProd;
@property (nonatomic, strong) NSString *airshipSecretProd;
@property (nonatomic, strong) NSString *adHoc;


+ (Config *)sharedConfig;
- (void)updateWithServerSettings;
@end
