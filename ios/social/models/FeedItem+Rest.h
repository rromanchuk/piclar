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

@interface FeedItem (Rest) <RESTable>
+ (FeedItem *)feedItemWithRestFeedItem:(RestFeedItem *)restFeedItem
             inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
@end
