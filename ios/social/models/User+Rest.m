

#import "User+Rest.h"

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
    self.fullName = restUser.fullName;
    self.email = restUser.email; 
    self.remoteProfilePhotoUrl = restUser.remoteProfilePhotoUrl;
    self.externalId = [NSNumber numberWithInt:restUser.externalId];
    self.token = restUser.token;
    self.location = restUser.location;
    self.gender = [NSNumber numberWithInteger:restUser.gender];
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
    [restUser pushToServer:onLoad onError:onError];
}

- (void)updateWithRestObject:(RestObject *)restObject {
    [self setManagedObjectWithIntermediateObject:restObject];
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


@end
