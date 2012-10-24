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


- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
- (void)updateUserSettings;

+ (User *)userWithRestUser:(RestUser *)restUser 
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithExternalId:(NSNumber *)externalId
      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithExternalId:(NSNumber *)externalId 
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (User *)userWithToken:(NSString *)token 
      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)saveUserImageToCoreData:(UIImage *)image
              withManagedObject:(User *)user;

+ (UIImage *)getUserImageFromCoreData:(User *)user;

- (void)saveUserImageToCoreData:(UIImage *)image;
- (UIImage *)getUserImageFromCoreData;
- (BOOL)hasPhoto;
- (NSString *)normalFullName;

- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError;

- (void)updateWithRestObject:(RestObject *)restObject;
- (void)updateFromServer:(void (^)(void))onLoad;
- (void)updateFromServer;


- (void)checkInvitationCode:(NSString *)code
                  onSuccess:(void (^)(void))onSuccess
                    onError:(void (^)(void))onError;
- (BOOL)isCurrentUser;
- (NSInteger)numberOfUnreadNotifications;

@end
