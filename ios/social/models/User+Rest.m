

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
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", externalId];
    
    NSError *error = nil;
    NSArray *users = [context executeFetchRequest:request error:&error];
    
    if (!users || ([users count] > 1)) {
        // handle error
        NSLog(@"FOUND MULTIPLE USERS");
    } else if (![users count]) {
        NSLog(@"NO USER FOUND");
    } else {
        NSLog(@"FOUND USER");
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

@end
