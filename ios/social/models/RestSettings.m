//
//  RestSettings.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/30/12.
//
//

#import "RestSettings.h"
#import "AFJSONUtilities.h"

@implementation RestSettings
static NSString *RESOURCE = @"api/v1/settings";

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"vkScopes", @"vk_scopes",
            @"vkClientId", @"vk_client_id",
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
        id JSON = AFJSONDecode(data, &error);
        restSettings = [RestSettings objectFromJSONObject:JSON mapping:[RestSettings mapping]];
        return restSettings;
    }
}
@end
