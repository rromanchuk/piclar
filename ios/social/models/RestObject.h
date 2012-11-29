//
//  RestObject.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface RestObject : NSObject
@property NSInteger externalId;
+ (NSString *)processError:(NSError *)error for:(NSString *)name withMessageFromServer:(NSString *)message __deprecated;
+ (NSError *)customError:(NSError *)error withServerResponse:(NSHTTPURLResponse *)response andJson:(id)JSON;
@end
