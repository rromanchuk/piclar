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
@property BOOL loadingPlacesFromServer;

+ (ThreadedUpdates *)shared;
- (void)loadNotificationsPassivelyForUser:(User *)user;
- (void)loadSuggestedUsersForUser:(NSNumber *)externalId;
- (void)loadPlacesPassivelyWithLat:(NSNumber*)lat andLon:(NSNumber*)lon;
- (void)loadPlacesPassivelyWithCurrentLocation;
- (void)loadFeedPassively;
- (void)loadFeedPassively:(NSNumber *)externalId;
- (void)loadFollowersPassively:(NSNumber *)externalId;
- (void)loadFeedItemPassively:(NSNumber*)feedItemId;
@end
