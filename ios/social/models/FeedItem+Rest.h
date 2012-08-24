//
//  FeedItem+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedItem.h"
#import "RESTable.h"
#import "RestFeedItem.h"
#import "RestComment.h"

@interface FeedItem (Rest) <RESTable>
+ (FeedItem *)feedItemWithRestFeedItem:(RestFeedItem *)restFeedItem
             inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)updateFeedItemWithRestFeedItem:(RestFeedItem *)restFeedItem;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

- (void)like:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSString *error))onError;

- (void)unlike:(void (^)(RestFeedItem *restFeedItem))onLoad
     onError:(void (^)(NSString *error))onError;

- (void)createComment:(NSString *)comment
               onLoad:(void (^)(RestComment *restComment))onLoad
              onError:(void (^)(NSString *error))onError;

@end
