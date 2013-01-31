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
@property (atomic, strong) NSString *vkUrl;
+ (RestSettings *)loadSettings;

@end
