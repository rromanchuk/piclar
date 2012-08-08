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

static NSString *FEED_RESOURCE = @"api/v1/feed";
static NSString *PERSON_RESOURCE = @"api/v1/person";

@implementation RestFeedItem
@synthesize favorites; 
@synthesize type;
@synthesize createdAt;
@synthesize checkin; 
@synthesize user;
@synthesize comments;


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"type", @"type",
            @"favorites", @"count_likes",
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
    NSLog(@"FEED INDEX REQUEST %@", request);
    
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            NSMutableArray *feedItems = [[NSMutableArray alloc] init];
                                                                                            if ([JSON count] > 0) {
                                                                                                for (id feedItem in JSON) {
                                                                                                    RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:feedItem mapping:[RestFeedItem mapping]];                                                                                                    
                                                                                        
                                                                                                    [feedItems addObject:restFeedItem];
                                                                                                }
                                                                                                                                                                                                                                                                                                
                                                                                                if (onLoad)
                                                                                                    onLoad(feedItems);
                                                                                            }
                                                                                            
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
    
}

+ (void)loadUserFeed:(void (^)(id object))onLoad 
         onError:(void (^)(NSString *error))onError
        withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"GET" andParams:params andToken:[RestUser currentUserToken]]; 
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"CHECKIN INDEX REQUEST %@", request);
    
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON %@", JSON);
                                                                                            NSMutableArray *checkins = [[NSMutableArray alloc] init];
                                                                                            if ([JSON count] > 0) {
                                                                                                for (id checkinDict in JSON) {
                                                                                                    id data = [checkinDict objectForKey:@"data"];
                                                                                                    id checkinDictionary = [data objectForKey:@"checkin"];
                                                                                                    NSSet *photos = [[NSSet alloc] init];
                                                                                                    NSLog(@"checkin dictionary is %@", checkinDictionary);
                                                                                                    RestCheckin *checkin = [RestCheckin objectFromJSONObject:checkinDictionary mapping:[RestCheckin mapping]];
                                                                                                    for (id photo in checkin.photos) {
                                                                                                        RestPhoto *restPhoto = [RestPhoto objectFromJSONObject:photo mapping:[RestPhoto mapping]];
                                                                                                        photos = [photos setByAddingObject:restPhoto];
                                                                                                    }
                                                                                                    checkin.photos = photos;
                                                                                                    [checkins addObject:checkin];
                                                                                                    NSLog(@"restCheckin object is %@", checkin);
                                                                                                }
                                                                                                
                                                                                                NSLog(@"restCheckin %@", checkins);
                                                                                                if (onLoad)
                                                                                                    onLoad(checkins);
                                                                                            }
                                                                                            
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
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
    NSLog(@"FEED ITEM LIKE %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];                                                                                            
                                                                                            
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];
    
}

+ (void)addComment:(NSNumber *)feedItemExternalId
           onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
          onError:(void (^)(NSString *error))onError {
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [FEED_RESOURCE stringByAppendingFormat:@"/%@/comment.json", feedItemExternalId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:path parameters:[RestClient defaultParametersWithParams:params]];
    NSLog(@"FEED ITEM COMMENT %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
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
    NSLog(@"FEED ITEM BY ID %@", request);
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
                                                                                            RestFeedItem *feedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(feedItem);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];


}

- (NSString *) description {
    return [NSString stringWithFormat:@"[RestFeedItem] EXTERNAL_ID: %d\nCREATED AT: %@\nUSER: %@\nCHECKIN: %@\n COMMENTS: %@",
            self.externalId, self.createdAt, self.user, self.checkin, self.comments];
}
@end
