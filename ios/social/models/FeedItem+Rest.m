//
//  FeedItem+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedItem+Rest.h"

@implementation FeedItem (Rest)
+ (FeedItem *)commentWithRestComment:(RestFeedItem *)restFeedItem
              inManagedObjectContext:(NSManagedObjectContext *)context {
    FeedItem *feedItem; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restFeedItem.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *feedItems = [context executeFetchRequest:request error:&error];
    
    if (!feedItems || ([feedItems count] > 1)) {
        // handle error
    } else if (![feedItems count]) {
        feedItem = [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem"
                                                inManagedObjectContext:context];
        [feedItem setManagedObjectWithIntermediateObject:restFeedItem];
    } else {
        feedItem = [feedItems lastObject];
    }
    
    return feedItem;

}
@end
