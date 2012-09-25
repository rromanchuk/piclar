//
//  RestSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/30/12.
//
//

#import "RestSettings.h"

@implementation RestSettings
static NSString *RESOURCE = @"api/v1/settings";

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"vkScopes", @"vk_scopes",
            @"vkClientId", @"vk_client_id",
            @"vkUrl", @"vk_url",
            nil];
}

#warning this is a blocking request! Use at your own risk!
+ (RestSettings *)loadSettings
{
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:@".json"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParameters]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    RestSettings *restSettings;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error) {
        return restSettings;
    } else {
        id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        restSettings = [RestSettings objectFromJSONObject:JSON mapping:[RestSettings mapping]];
        return restSettings;
    }
}

- (NSString *) description {
    return [NSString stringWithFormat:@"vkScopes: %@\nvkClientId: %@\nvkUrl: %@",
            self.vkScopes, self.vkClientId, self.vkUrl];
}

@end
