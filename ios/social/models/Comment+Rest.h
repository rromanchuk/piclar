//
//  Comment+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Comment.h"
#import "RESTable.h"
#import "RestComment.h"
#import "RestFeedItem.h"
@interface Comment (Rest) <RESTable>

+ (Comment *)commentWithRestComment:(RestComment *)restComment 
       inManagedObjectContext:(NSManagedObjectContext *)context;
- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

- (void)deleteComment:(void (^)(RestFeedItem *restFeedItem))onLoad
              onError:(void (^)(NSError *error))onError;

@end
