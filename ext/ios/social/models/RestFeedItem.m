//
//  RestFeedItem.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RestFeedItem.h"
#import "RailsRestClient.h"
#import "RestComment.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import <SystemConfiguration/SystemConfiguration.h>

static NSString *RAILS_FEED_RESOURCE = @"feed_items";
static NSString *RAILS_CHECKIN_RESOURCE = @"feed_items";


@implementation RestFeedItem

+ (NSDictionary *)mapping {
    return [self mapping:FALSE];
}

+ (NSDictionary *)mapping:(BOOL)is_nested {
    NSMutableDictionary *map =  [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"placeId", @"place_id",
            @"review", @"review",
            @"rating", @"rating",
            //@"type", @"type",
            @"meLiked", @"me_liked",
            @"showInFeed", @"show_in_feed",
            @"isActive", @"is_active",
            @"photoUrl", @"photo_url",
            @"thumbPhotoUrl", @"thumb_photo_url",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"], @"created_at",
            [NSDate mappingWithKey:@"sharedAt"
                  dateFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"], @"created_at",
            [RestPlace mappingWithKey:@"place" mapping:[RestPlace mapping]], @"place",
            [RestUser mappingWithKey:@"user"
                             mapping:[RestUser mapping]], @"user",
            [RestComment mappingWithKey:@"comments" mapping:[RestComment mapping]], @"comments",
            [RestUser mappingWithKey:@"liked" mapping:[RestUser mapping]], @"likes",
            nil];
//    if (!is_nested) {
//            [map setObject:[RestPlace mappingWithKey:@"place" mapping:[RestPlace mapping:YES]] forKey:@"place"];
//    }
    return map;
}
+ (void)createFeedItemWithPlace:(NSNumber *)placeId
                      andPhoto:(NSMutableData *)photo
                    andComment:(NSString *)comment
                     andRating:(NSNumber *)rating
              shareOnPlatforms:(NSArray *)platforms
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSError *error))onError;
{
    //RestClient *restClient = [RestClient sharedClient];
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    
    NSString *path = [RAILS_CHECKIN_RESOURCE stringByAppendingString:@".json"];
    
//    NSNumber *lat = [Location sharedLocation].latitude;
//    NSNumber *lng = [Location sharedLocation].longitude;
    //NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:placeId, @"place_id", rating, @"rate", comment, @"review", nil];
    
    NSDictionary *_params = @{@"place[id]": placeId, @"feed_item[rating]": rating, @"feed_item[review]": comment, @"auth_token": [RestUser currentUserToken]};
    NSMutableDictionary *params = [_params mutableCopy];
    
    //    if (lat && lng) {
    //        [params setObject:[NSString stringWithFormat:@"%g", [lat doubleValue]] forKey:@"lat"];
    //        [params setObject:[NSString stringWithFormat:@"%g", [lng doubleValue]] forKey:@"lng"];
    //    }
    
    for (NSString *platform in platforms) {
        [params setValue:@"true" forKey:[NSString stringWithFormat:@"share_%@", platform]];
    }
    
    
    NSMutableURLRequest *request = [railsRestClient multipartFormRequestWithMethod:@"POST"
                                                                              path:path
                                                                        parameters:[RestClient defaultParametersWithParams:params]
                                                         constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                    {
                                        
                                        [formData appendPartWithFileData:photo
                                                                    name:@"feed_item[photo]"
                                                                fileName:@"my_photo.jpg"
                                                                mimeType:@"image/jpeg"];
                                    }];
    DLog(@"CHECKIN CREATE REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"Checkin create JSON: %@", JSON);
                                                                                            RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
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


+ (void)loadFeed:(void (^)(id object))onLoad 
          onError:(void (^)(NSError *error))onError
          {
    
    //RestClient *restClient = [RestClient sharedClient];
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
              
    //NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    //NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"GET" path:path parameters:nil];
    
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET" path:RAILS_FEED_RESOURCE parameters:nil];
    ALog(@"FEED INDEX REQUEST %@", request);
    
    
        
    AFJSONRequestOperation *operation =
              [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                  [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                  DLog(@"Feed item json %@", JSON);
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
                                                                          if (onLoad) {
                                                                              onLoad(feedItems);
                                                                          }
                                                                      });
                                                                  });
                                                              }

                                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                  [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                  DLog(@"code from error %d and code from response %d and error message %@", response.statusCode, error.code, error.localizedDescription);
                                                                  NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                  if (onError) {
                                                                      onError(customError);
                                                                  }
                                                              }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}


+ (void)like:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@/likes.json", feedItemExternalId];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"POST" path:path parameters:nil];
    ALog(@"Like feed item %@", request);
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                        //DLog(@"Like JSON %@", JSON);
                                                        
                                                        RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                        
                                                        if (onLoad) {
                                                            onLoad(feedItem);
                                                        }
                                                        
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                        NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                        if (onError) {
                                                            onError(customError);
                                                        }
                                                    }
         ];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

+ (void)unlike:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *))onLoad
     onError:(void (^)(NSError *error))onError {
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@/unlike.json", feedItemExternalId];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"DELETE" path:path parameters:nil];
    DLog(@"Unlike feed item %@", request);
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@/comments/%@.json", feedItemExternalId, commentExternalId];
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"DELETE" path:path parameters:nil];
    DLog(@"Unlike feed item %@", request);
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    //RestClient *restClient = [RestClient sharedClient];
    //NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/comment.json", feedItemExternalId];
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@/comments.json", feedItemExternalId];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"POST" path:path parameters:@{@"comment[comment]" : comment}]; //[restClient signedRequestWithMethod:@"POST" path:path parameters:@{@"comment" : comment}];
    DLog(@"FEED ITEM COMMENT %@", request);
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                        
                                                        RestComment *restComment = [RestComment objectFromJSONObject:JSON mapping:[RestComment mapping]];
                                                        
                                                        DLog(@" ADD COMMENT JSON %@", JSON);
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
    
    //RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@.json", identifier];
    
    RailsRestClient *railsRestClient = [RailsRestClient sharedClient];
    NSMutableURLRequest *request = [railsRestClient signedRequestWithMethod:@"GET" path:path parameters:nil];
    ALog(@"FEED ITEM BY ID %@", request);
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    RailsRestClient *restClient = [RailsRestClient sharedClient];
    NSDictionary *params = [[NSDictionary alloc] init];
    NSString *path = [RAILS_FEED_RESOURCE stringByAppendingFormat:@"/%@.json", feedItemExternalId];
    NSMutableURLRequest *request = [restClient signedRequestWithMethod:@"DELETE" path:path parameters:params];
    ALog(@"delete feed item %@", request);
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId", self.createdAt, @"createdAt", self.user, @"user", self.comments, @"comments", [NSNumber numberWithBool:self.isActive], @"isActive", nil];
    return [dict description];
}
@end
