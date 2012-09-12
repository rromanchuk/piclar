//
//  RestNotification.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "RestNotification.h"
#import "RestClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "RestUser.h"
static NSString *NOTIFICATION_RESOURCE = @"api/v1/notification";

@implementation RestNotification

@synthesize type;
@synthesize createdAt;
@synthesize isRead;
@synthesize notificationType;
@synthesize sender;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"isRead", @"is_read",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"sender"
                             mapping:[RestUser mapping]], @"sender",
            @"notificationType", @"notification_type",
            @"type", @"type",
            nil];
}

+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [NOTIFICATION_RESOURCE stringByAppendingString:@"/list.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"FEED INDEX REQUEST %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"Feed item json %@", JSON);
                                                                                            NSMutableSet *notificationItems = [[NSMutableSet alloc] init];
                                                                                            if ([JSON count] > 0) {
                                                                                                for (id feedItem in JSON) {
                                                                                                    RestNotification *restNotification = [RestNotification objectFromJSONObject:feedItem mapping:[RestNotification mapping]];
                                                                                                    [notificationItems addObject:restNotification];
                                                                                                }
                                                                                                
                                                                                                if (onLoad)
                                                                                                    onLoad(notificationItems);
                                                                                            }
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_NOTIFICATIONS" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

+ (void)markAllAsRead:(void (^)(NSSet *notificationItems))onLoad
              onError:(void (^)(NSString *error))onError {
    
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestNotification] externalId: %d\ncreatedAt: %@\nisRead: %d\nnotificationType: %d\ntype: %@\nsender: %@\n",
            self.externalId, self.createdAt, self.isRead, self.notificationType, self.type, self.sender];
}

@end
