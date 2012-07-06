
#import <Foundation/Foundation.h>

#import "Config.h"
@interface Config : NSObject

@property (nonatomic, strong) NSString *vkAppId;
@property (nonatomic, strong) NSString *vkSecretId;
@property (nonatomic, strong) NSString *vkPermissions; 

+ (Config *)sharedConfig;
@end
