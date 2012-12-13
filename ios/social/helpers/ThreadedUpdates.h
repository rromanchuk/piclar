//
//  ThreadedUpdates.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/1/12.
//
//

#import <Foundation/Foundation.h>
#import "User+Rest.h"

@interface ThreadedUpdates : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (ThreadedUpdates *)shared;
- (void)loadNotificationsPassivelyForUser:(User *)user;
- (void)loadSuggestedUsersForUser:(NSNumber *)externalId;
- (void)loadPlacesPassively;
- (void)loadFeedPassively;
- (void)loadFeedPassively:(NSNumber *)externalId;
- (void)loadFollowersPassively:(NSNumber *)externalId;
- (void)loadFeedItemPassively:(NSNumber*)feedItemId;
- (dispatch_queue_t)getOstronautQueue;
@end
