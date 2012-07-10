
@interface Config : NSObject

@property (nonatomic, strong) NSString *vkAppId;
@property (nonatomic, strong) NSString *vkSecretId;
@property (nonatomic, strong) NSString *vkPermissions; 
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *secureBaseURL;
@property (nonatomic, strong) NSString *apiVersion;

+ (Config *)sharedConfig;
@end
