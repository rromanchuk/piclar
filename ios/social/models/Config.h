//
//  Config.h
//  social
//
//  Created by Ryan Romanchuk on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Config.h"
@interface Config : NSObject

@property (nonatomic, strong) NSString *vkAppId;
@property (nonatomic, strong) NSString *vkSecretId;

+ (Config *)sharedConfig;
@end
