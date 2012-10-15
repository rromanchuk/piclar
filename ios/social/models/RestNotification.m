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
@synthesize placeTitle;
@synthesize feedItem;
+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"isRead", @"is_read",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"sender"
                             mapping:[RestUser mapping]], @"sender",
            [RestFeedItem mappingWithKey:@"feedItem"
                             mapping:[RestUser mapping]], @"feed_item",
            @"notificationType", @"notification_type",
            @"type", @"type",
            @"placeTitle", @"place_title",
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
    DLog(@"Notifications index request %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Feed item json %@", JSON);
                                                                                            
                                                                                            
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                // Add code here to do background processing
                                                                                                NSMutableSet *notificationItems = [[NSMutableSet alloc] init];
                                                                                                if ([JSON count] > 0) {
                                                                                                    for (id feedItem in JSON) {
                                                                                                        RestNotification *restNotification = [RestNotification objectFromJSONObject:feedItem mapping:[RestNotification mapping]];
                                                                                                        [notificationItems addObject:restNotification];
                                                                                                    }
                                                                                                    
                                                                                                }

                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                    // Add code here to update the UI/send notifications based on the
                                                                                                    // results of the background processing
                                                                                                    if (onLoad)
                                                                                                        onLoad(notificationItems);
                                                                                                });
                                                                                            });
                                                                                            
                                                                                            
                                                                                            
                                                                                            
                                                                                            
                                                                                            
                                                                                                                                                                                        

                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_NOTIFICATIONS" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    operation.threadPriority = 0.3;
    [operation start];
    
}


+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestNotification *restNotification))onLoad
                 onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [NOTIFICATION_RESOURCE stringByAppendingFormat:@"/%@.json", identifier];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Notifications index request %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Feed item json %@", JSON);
                                                                                            RestNotification *restNotification = [RestNotification objectFromJSONObject:JSON mapping:[RestNotification mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(restNotification);
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"NOTIFICATION_BY_IDENTIFIER" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)markAllAsRead:(void (^)(bool status))onLoad
              onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [NOTIFICATION_RESOURCE stringByAppendingString:@"/markasread.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Mark all as read request %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Feed item json %@", JSON);
                                    
                                                                                            if (onLoad)
                                                                                                onLoad(YES);
                                                                                                                                                                                        
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"MARK_NOTIFICATIONS_AS_READ" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

- (NSString *)description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId", self.createdAt, @"createdAt", [NSNumber numberWithInteger:self.isRead], @"isRead",  [NSNumber numberWithInteger:self.notificationType], @"notificationType", self.type, @"type", [self.sender description], @"sender", [self.feedItem description], @"feedItem", nil];
    return [dict description];
}

@end
