//
//  RestFeedItem.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "RestCheckin.h"
#import "RestUser.h"
#import "RestComment.h"

@interface RestFeedItem : RestObject
@property NSInteger meLiked;
@property NSInteger placeId;

@property NSInteger rating;

@property BOOL isActive;
@property BOOL showInFeed;

@property (atomic, strong) NSString *type;
@property (atomic, strong) NSString *review;
@property (atomic, strong) NSString *photoUrl;
@property (atomic, strong) NSString *thumbPhotoUrl;

@property (atomic, strong) NSDate *createdAt;
@property (atomic, strong) NSDate *sharedAt;
@property (atomic, strong) RestUser *user;
@property (atomic, strong) NSSet *comments; 
@property (atomic, strong) NSSet *liked;

+ (void)createFeedItemWithPlace:(NSNumber *)placeId
                      andPhoto:(NSMutableData *)photo
                    andComment:(NSString *)comment
                     andRating:(NSNumber *)rating
              shareOnPlatforms:(NSArray *)platforms
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSError *error))onError;

+ (void)loadFeed:(void (^)(id object))onLoad
         onError:(void (^)(NSError *error))onError;

+ (void)like:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSError *error))onError;

+ (void)unlike:(NSNumber *)feedItemExternalId
      onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSError *error))onError;

+ (void)deleteComment:(NSNumber *)feedItemExternalId
        commentExternalId:(NSNumber *)commentExternalId
        onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
       onError:(void (^)(NSError *error))onError;

+ (void)deleteFeedItem:(NSNumber *)feedItemExternalId
               onLoad:(void (^)(RestFeedItem *restFeedItem))onLoad
              onError:(void (^)(NSError *error))onError;

+ (void)addComment:(NSNumber *)feedItemExternalId
            withComment:(NSString *)comment
                  onLoad:(void (^)(RestComment *restComment))onLoad
                 onError:(void (^)(NSError *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSError *error))onError;

+ (NSDictionary *)mapping;
@end
