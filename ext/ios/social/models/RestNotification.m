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
#import "RailsRestClient.h"

static NSString *RAILS_NOTIFICATION_RESOURCE = @"notifications";

@implementation RestNotification


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"isRead", @"is_read",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"sender"
                             mapping:[RestUser mapping]], @"sender",
            @"feedItemId", @"feed_item.id",
            @"notificationType", @"notification_type",
            @"type", @"type",
            @"placeTitle", @"place_title",
            @"isActive", @"is_active",
            nil];
}

+ (void)load:(void (^)(NSSet *notificationItems))onLoad
     onError:(void (^)(NSError *error))onError {
    
    //RestClient *restClient = [RestClient sharedClient];
    //NSString *path = [NOTIFICATION_RESOURCE stringByAppendingString:@"/list.json"];
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_NOTIFICATION_RESOURCE stringByAppendingString:@".json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET" path:path parameters:params]; //[restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Notifications index request %@", request);
    

    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"Feed item json %@", JSON);
                                                                                            
                                                                                            
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
                                                                                            
                                                                                            
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    operation.threadPriority = 0.3;
    [operation start];
    
}


+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(RestNotification *restNotification))onLoad
                 onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_NOTIFICATION_RESOURCE stringByAppendingFormat:@"/%@.json", identifier];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
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
                                                                                            
                                                                                            
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)markAllAsRead:(void (^)(bool status))onLoad
              onError:(void (^)(NSError *error))onError {
    
    //RestClient *restClient = [RestClient sharedClient];
    //NSString *path = [NOTIFICATION_RESOURCE stringByAppendingString:@"/markasread.json"];
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_NOTIFICATION_RESOURCE stringByAppendingString:@"/mark_as_read.json"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"POST" path:path parameters:params];
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
                                                                                            
                                                                                            
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

- (NSString *)description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId", self.createdAt, @"createdAt", [NSNumber numberWithInteger:self.isRead], @"isRead",  [NSNumber numberWithInteger:self.notificationType], @"notificationType", self.type, @"type", [self.sender description], @"sender", [NSNumber numberWithInteger:self.feedItemId], @"feedItemId", [NSNumber numberWithBool:self.isActive], @"isActive", nil];
    return [dict description];
}

@end
