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
- (id)initWithContext:(NSManagedObjectContext *)context;
- (void)loadNotificationsPassivelyForUser:(User *)user;
- (void)loadPlacesPassively;
- (void)loadFeedPassively;
@end
