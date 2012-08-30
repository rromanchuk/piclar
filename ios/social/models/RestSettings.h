//
//  RestSettings.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/30/12.
//
//

#import "RestObject.h"

@interface RestSettings : RestObject
@property (atomic, strong) NSString *vkScopes;
@property (atomic, strong) NSString *vkClientId;

+ (void)loadSettings:(void (^)(RestSettings *))onLoad
             onError:(void (^)(NSString *error))onError;
@end
