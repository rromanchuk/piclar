//
//  User+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "RestUser.h"
#import "RESTable.h"
@interface User (Rest) <RESTable>
// Common
+ (User *)userWithRestUser:(RestUser *)restUser inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)userWithExternalId:(NSNumber *)externalId inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)findOrCreateUserWithRestUser:(RestUser *)user
                inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

// Suggested 
+ (NSArray *)suggestedUsers:(NSManagedObjectContext *)context;


+ (void)saveUserImageToCoreData:(UIImage *)image
              withManagedObject:(User *)user;
- (void)saveUserImageToCoreData:(UIImage *)image;
+ (UIImage *)getUserImageFromCoreData:(User *)user;
- (UIImage *)getUserImageFromCoreData;


- (NSString *)fullName;
- (BOOL)hasPhoto;
- (BOOL)isCurrentUser;
- (NSInteger)numberOfUnreadNotifications;


- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSError *error))onError;
- (void)updateFromServer:(void (^)(void))onLoad;
- (void)updateFromServer;
- (void)updateUserSettings;

- (void)checkInvitationCode:(NSString *)code
                  onSuccess:(void (^)(void))onSuccess
                    onError:(void (^)(void))onError;

- (void)syncFollowing:(NSSet *)restUsers;
- (void)syncFollowers:(NSSet *)restUsers;

@end
