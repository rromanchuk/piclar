
#import <Foundation/Foundation.h>

#import "Config.h"
@interface Config : NSObject

@property (nonatomic, strong) NSString *vkAppId;
@property (nonatomic, strong) NSString *vkSecretId;

+ (Config *)sharedConfig;
@end
