//
//  RestFeedItem.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestFeedItem.h"
#import "RestClient.h"
#import "RestComment.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import <SystemConfiguration/SystemConfiguration.h>

static NSString *FEED_RESOURCE = @"api/v1/feed";
static NSString *PERSON_RESOURCE = @"api/v1/person";

@implementation RestFeedItem


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"type", @"type",
            @"favorites", @"count_likes",
            @"meLiked", @"me_liked",
            @"showInFeed", @"show_in_my_feed",
            @"isActive", @"is_active",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"sharedAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"share_date",

            [RestUser mappingWithKey:@"user"
                             mapping:[RestUser mapping]], @"creator",
            [RestCheckin mappingWithKey:@"checkin" mapping:[RestCheckin mapping]], @"checkin",
            [RestComment mappingWithKey:@"comments" mapping:[RestComment mapping]], @"comments",
            [RestUser mappingWithKey:@"liked" mapping:[RestUser mapping]], @"liked",
            nil];
}

+ (void)loadFeed:(void (^)(id object))onLoad 
          onError:(void (^)(NSError *error))onError
          {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    ALog(@"FEED INDEX REQUEST %@", request);
    
    
        
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Feed item json %@", JSON);
                                                                                            
                                                                                            
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                // Add code here to do background processing
                                                                                                NSMutableArray *feedItems = [[NSMutableArray alloc] init];
                                                                                                if ([JSON count] > 0) {
                                                                                                    for (id feedItem in JSON) {
                                                                                                        RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];
                                                                                                        
                                                                                                        [feedItems addObject:restFeedItem];
                                                                                                    }
                                                                                                }
                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                    if (onLoad)
                                                                                                        onLoad(feedItems);
                                                                                                });
                                                                                            });
                                                                                            
                                                                                            
                                                                                            
                                                                                                                                                                                        
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            DLog(@"code from error %d and code from response %d and error message %@", response.statusCode, error.code, error.localizedDescription);
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}


+ (void)like:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSError *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/like.json", feedItemExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    ALog(@"Like feed item %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];                                                                                            
                                                                                            //DLog(@"Like JSON %@", JSON);
                                                                                            
                                                                                                RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                                if (onLoad)
                                                                                                    onLoad(feedItem);
                                                                                            
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

+ (void)unlike:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSError *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/unlike.json", feedItemExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Unlike feed item %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Unlike JSON %@", JSON);
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
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


+ (void)deleteComment:(NSNumber *)feedItemExternalId commentExternalId:(NSNumber *)commentExternalId
        onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
       onError:(void (^)(NSError *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/comment/%@/delete.json", feedItemExternalId, commentExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Unlike feed item %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"Unlike JSON %@", JSON);
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
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

+ (void)addComment:(NSNumber *)feedItemExternalId
       withComment:(NSError *)comment
           onLoad:(void (^)(RestComment *restComment))onLoad
          onError:(void (^)(NSError *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/comment.json", feedItemExternalId];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"FEED ITEM COMMENT %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            RestComment *restComment = [RestComment objectFromJSONObject:JSON mapping:[RestComment mapping]];
                                                                                            
                                                                                            //DLog(@" ADD COMMENT JSON %@", JSON);
                                                                                            if (onLoad)
                                                                                                onLoad(restComment);
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

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSError *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@.json", identifier];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    ALog(@"FEED ITEM BY ID %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            //DLog(@"%@", JSON);
                                                                                            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                                RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                                dispatch_async( dispatch_get_main_queue(), ^{
                                                                                                    if (onLoad)
                                                                                                        onLoad(feedItem);
                                                                                                    
                                                                                                });
                                                                                            });
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            ALog(@"error is %@", error);
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

+ (void)deleteFeedItem:(NSNumber *)feedItemExternalId
                onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
               onError:(void (^)(NSError *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/delete.json", feedItemExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    ALog(@"delete feed item %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            //DLog(@" ADD COMMENT JSON %@", JSON);
                                                                                            if (onLoad)
                                                                                                onLoad(restFeedItem);
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

- (NSString *) description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId", self.createdAt, @"createdAt", self.user, @"user", self.checkin, @"checkin", self.comments, @"comments", nil];
    return [dict description];
}
@end
