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
@synthesize favorites; 
@synthesize type;
@synthesize createdAt;
@synthesize checkin; 
@synthesize user;
@synthesize comments;
@synthesize meLiked;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"type", @"type",
            @"favorites", @"count_likes",
            @"meLiked", @"me_liked",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user"
                             mapping:[RestUser mapping]], @"creator",
            [RestCheckin mappingWithKey:@"checkin" mapping:[RestCheckin mapping]], @"checkin",
            [RestComment mappingWithKey:@"comments" mapping:[RestComment mapping]], @"comments",
            nil];
}

+ (void)loadFeed:(void (^)(id object))onLoad 
          onError:(void (^)(NSString *error))onError
         withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"FEED INDEX REQUEST %@", request);
    
    
    dispatch_queue_t requestQueue = dispatch_queue_create("requestQueue", NULL);
    AFHTTPRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    operation.successCallbackQueue = requestQueue;
    operation.failureCallbackQueue = requestQueue;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        DLog(@"Feed item json %@", JSON);
        NSMutableArray *feedItems = [[NSMutableArray alloc] init];
        if ([JSON count] > 0) {
            for (id feedItem in JSON) {
                RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];
                
                [feedItems addObject:restFeedItem];
            }
            
            if (onLoad)
                onLoad(feedItems);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        id JSON = ((AFJSONRequestOperation *)operation).responseJSON;
        DLog(@"code from error %d and code from response %d and error message %@", operation.response.statusCode, error.code, error.localizedDescription);
        NSString *publicMessage = [RestObject processError:error for:@"LOAD_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
        if (onError)
            onError(error.localizedDescription);
    }];
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                            DLog(@"Feed item json %@", JSON);
//                                                                                            NSMutableArray *feedItems = [[NSMutableArray alloc] init];
//                                                                                            if ([JSON count] > 0) {
//                                                                                                for (id feedItem in JSON) {
//                                                                                                    RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];
//                                                                                        
//                                                                                                    [feedItems addObject:restFeedItem];
//                                                                                                }
//                                                                                                                                                                                                                                                                                                
//                                                                                                if (onLoad)
//                                                                                                    onLoad(feedItems);
//                                                                                            }
//                                                                                            
//                                                                                        } 
//                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                            
//                                                                                            DLog(@"code from error %d and code from response %d and error message %@", response.statusCode, error.code, error.localizedDescription);
//                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
//                                                                                            if (onError)
//                                                                                                onError(publicMessage);
//                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}

+ (void)loadUserFeed:(NSNumber *)userExternalId
              onLoad:(void (^)(NSSet *feedItems))onLoad
         onError:(void (^)(NSString *error))onError
        withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingFormat:@"/%@/feed.json",userExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"FeedItems for user %@", request);
    dispatch_queue_t requestQueue = dispatch_queue_create("requestQueue", NULL);
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    operation.successCallbackQueue = requestQueue;
    operation.failureCallbackQueue = requestQueue;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        DLog(@"Feed items for user %@", JSON);
        NSMutableSet *feedItems = [[NSMutableSet alloc] init];
        if ([JSON count] > 0) {
            for (id feedItem in JSON) {
                RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];
                [feedItems addObject:restFeedItem];
            }
            
            if (onLoad)
                onLoad(feedItems);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        id JSON = ((AFJSONRequestOperation *)operation).responseJSON;
        NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
        
        if (onError)
            onError(publicMessage);
    }];
    
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                            DLog(@"Feed items for user %@", JSON);
//                                                                                            NSMutableSet *feedItems = [[NSMutableSet alloc] init];
//                                                                                            if ([JSON count] > 0) {
//                                                                                                for (id feedItem in JSON) {
//                                                                                                    RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];
//                                                                                                    [feedItems addObject:restFeedItem];
//                                                                                                }
//                                                                                                                                                                                                
//                                                                                                if (onLoad)
//                                                                                                    onLoad(feedItems);
//                                                                                            }
//                                                                                            
//                                                                                        } 
//                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
//                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_USER_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
//                                                                                            
//                                                                                            if (onError)
//                                                                                                onError(publicMessage);
//                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}

+ (void)like:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/like.json", feedItemExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"Like feed item %@", request);
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
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LIKE_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

+ (void)unlike:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSString *error))onError {
    
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
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"UNLIKE_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}


+ (void)addComment:(NSNumber *)feedItemExternalId
       withComment:(NSString *)comment
           onLoad:(void (^)(RestComment *restComment))onLoad
          onError:(void (^)(NSString *error))onError {
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
                                                                                            
                                                                                            DLog(@" ADD COMMENT JSON %@", JSON);
                                                                                            if (onLoad)
                                                                                                onLoad(restComment);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"ADD_COMMENT_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@.json", identifier];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    DLog(@"FEED ITEM BY ID %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"%@", JSON);
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *publicMessage = [RestObject processError:error for:@"LOAD_BY_IDENTIFIER_FEED_REQUEST" withMessageFromServer:[JSON objectForKey:@"message"]];
                                                                                            if (onError)
                                                                                                onError(publicMessage);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestFeedItem] EXTERNAL_ID: %d\nCREATED AT: %@\nUSER: %@\nCHECKIN: %@\n COMMENTS: %@",
            self.externalId, self.createdAt, self.user, self.checkin, self.comments];
}
@end
