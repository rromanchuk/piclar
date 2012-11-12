

#import "User+Rest.h"
#import "RestUserSettings.h"
#import "UserSettings+Rest.h"

@implementation User (Rest)
+ (User *)userWithRestUser:(RestUser *)restUser 
    inManagedObjectContext:(NSManagedObjectContext *)context {
    
    User *user;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restUser.externalId]];
   
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
    } else if (![users count]) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                                     inManagedObjectContext:context];
        
        [user setManagedObjectWithIntermediateObject:restUser];
        
    } else {
        user = [users lastObject];
        [user setManagedObjectWithIntermediateObject:restUser];
    }
    return user;
}

+ (User *)userWithExternalId:(NSNumber *)externalId
    inManagedObjectContext:(NSManagedObjectContext *)context {
    
    User *user;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@",externalId];
    
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
        user = nil;
    } else if (![users count]) {
        user = nil;
    } else {
        user = [users lastObject];
    }
    
    return user;
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestUser *restUser = (RestUser *) intermediateObject; 
    self.firstname = restUser.firstName;
    self.lastname = restUser.lastName;
    self.checkinsCount = [NSNumber numberWithInt:restUser.checkinsCount];
    self.fullName = restUser.fullName;
    self.email = restUser.email; 
    self.remoteProfilePhotoUrl = restUser.remoteProfilePhotoUrl;
    self.externalId = [NSNumber numberWithInt:restUser.externalId];
    self.token = restUser.token;
    self.location = restUser.location;
    self.gender = [NSNumber numberWithInteger:restUser.gender];
    self.birthday = restUser.birthday;
    self.registrationStatus = [NSNumber numberWithInteger:restUser.registrationStatus];
    self.isFollowed = [NSNumber numberWithInteger:restUser.isFollowed];
    self.modifiedDate = restUser.modifiedDate;
}

+ (void)saveUserImageToCoreData:(UIImage *)image
              withManagedObject:(User *)user {
    NSData *imageData = UIImagePNGRepresentation(image);
    user.profilePhoto = imageData;
}

- (void)saveUserImageToCoreData:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    self.profilePhoto = imageData;
}

- (NSString *)normalFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
}

-(NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.lastname, self.firstname];
}

- (BOOL)hasPhoto {
    if (self.profilePhoto) {
        return YES;
    } else {
        return NO;
    }
}

- (UIImage *)getUserImageFromCoreData {
    UIImage *image = [UIImage imageWithData:self.profilePhoto];
    return image;
}


+ (UIImage *)getUserImageFromCoreData:(User *)user {
    UIImage *image = [UIImage imageWithData:user.profilePhoto];
    return image;
}


- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError {
    DLog(@"INSIDE PUSHTOSERVER");
    RestUser *restUser = [[RestUser alloc] init];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'

    restUser.firstName = self.firstname;
    restUser.lastName = self.lastname;
    restUser.email = self.email;
    restUser.location = self.location;
    restUser.birthday = self.birthday;
    [restUser pushToServer:^(RestUser *user){
        [self updateWithRestObject:user];
        if (onLoad) {
            onLoad(user);
        }
    } onError:onError];
}

- (void)updateWithRestObject:(RestObject *)restObject {
    [self setManagedObjectWithIntermediateObject:restObject];
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        DLog(@"%@", error);
    }
}

- (BOOL)isCurrentUser {
    DLog(@"externalId is %@", [self.externalId stringValue]);
     DLog(@"%@", [[RestUser currentUserId] stringValue]);
    if ([[self.externalId stringValue] isEqualToString:[[RestUser currentUserId] stringValue]] ) {
        DLog(@"is current user");
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)numberOfUnreadNotifications {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRead == %@", [NSNumber numberWithBool:NO]];
    NSSet *notifications = [self.notifications filteredSetUsingPredicate:predicate];
    return [notifications count];
}


- (void)updateFromServer:(void (^)(void))onLoad {
    [RestUser loadByIdentifier:self.externalId onLoad:^(RestUser *restUser) {
        [self updateWithRestObject:restUser];
        if (onLoad) {
            onLoad();
        }
    } onError:^(NSString *error) {
        DLog(@"Could not update user");
        if (onLoad) {
            onLoad();
        }
    }];
}

- (void)updateFromServer {
    [self updateFromServer:^(void) {
        
    }];
}


- (void)updateUserSettings {
    [RestUserSettings load:^(RestUserSettings *restUserSettings) {
        if (self.settings) {
            [self.settings updateUserSettingsWithRestUserSettings:restUserSettings];
        } else {
            [UserSettings userSettingsWithRestNotification:restUserSettings inManagedObjectContext:self.managedObjectContext forUser:self];
        }

    } onError:^(NSString *error) {
        DLog(@"Could not update user settings");

    }];
    
}

- (void)checkInvitationCode:(NSString *)code
            onSuccess:(void (^)(void))onSuccess
            onError:(void (^)(void))onError {
    RestUser *restUser = [[RestUser alloc] init];
                
    [restUser checkCode:code onLoad:^(RestUser *user) {
        [self updateWithRestObject:user];
        if (onSuccess) {
            onSuccess();
        }
    } onError:^(NSString *error) {
        if (onError) {
            onError();
        }
    }];
}


- (void)syncFollowing:(NSSet *)restUsers {
    DLog(@"Making sure comments are synced");
    
    // OK let's add all these following to the user
    NSMutableSet *followingFromServer = [[NSMutableSet alloc] init];
    for (RestUser *restUser in restUsers) {
        [followingFromServer addObject:[User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext]];
    }
    [self addFollowing:followingFromServer];
    DLog(@"following from server are %@", followingFromServer);
    
    // If the number of following it means the server has something different, lets go with the server
    if ([self.following count] != [followingFromServer count]) {
        DLog(@"Following are not synchronized");
        DLog(@"follwing from coredate are %@", self.following);
        NSMutableSet *followingFromCoreData = [NSMutableSet setWithSet:self.following];
        //[likersFromServer minusSet:likersFromCoreData];
        [followingFromCoreData minusSet:followingFromServer];
        DLog(@"after minus set (commentsFromCoreData %@", followingFromCoreData);
        DLog(@"after minus set (commentsFromServer %@", followingFromServer);
        
        [self removeFollowing:followingFromCoreData];
        
    }
}


- (void)syncFollowers:(NSSet *)restUsers {
    DLog(@"Making sure comments are synced");
    NSMutableSet *followersFromServer = [[NSMutableSet alloc] init];
    for (RestUser *restUser in restUsers) {
        [followersFromServer addObject:[User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext]];
    }
    [self addFollowing:followersFromServer];
    DLog(@"following from server are %@", followersFromServer);
    
    if ([self.followers count] != [followersFromServer count]) {
        DLog(@"Followers are not synchronized");
        DLog(@"follwers from coredate are %@", self.followers);
        NSMutableSet *followersFromCoreData = [NSMutableSet setWithSet:self.following];
        //[likersFromServer minusSet:likersFromCoreData];
        [followersFromCoreData minusSet:followersFromServer];
        DLog(@"after minus set (commentsFromCoreData %@", followersFromCoreData);
        DLog(@"after minus set (commentsFromServer %@", followersFromServer);
        
        [self removeFollowing:followersFromCoreData];
    }
}


@end
