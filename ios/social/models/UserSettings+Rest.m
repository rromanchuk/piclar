//
//  UserSettings+Rest.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "UserSettings+Rest.h"
#import "RestUserSettings.h"
@implementation UserSettings (Rest)

+ (UserSettings *)userSettingsWithRestNotification:(RestUserSettings *)restUserSettings
                           inManagedObjectContext:(NSManagedObjectContext *)context
                            forUser:(User *)user{
    UserSettings *userSettings;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserSettings"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", user];
    
    NSError *error = nil;
    NSArray *userSettingsArr = [context executeFetchRequest:request error:&error];
    
    if (!userSettingsArr || ([userSettingsArr count] > 1)) {
        // handle error
    } else if (![userSettingsArr count]) {
        userSettings = [NSEntityDescription insertNewObjectForEntityForName:@"UserSettings"
                                                     inManagedObjectContext:context];
        
        [userSettings setManagedObjectWithIntermediateObject:restUserSettings];
        
    } else {
        userSettings = [userSettingsArr lastObject];
        [userSettings setManagedObjectWithIntermediateObject:restUserSettings];

    }
    user.settings = userSettings;
    return userSettings;
    
}

- (void)updateUserSettingsWithRestUserSettings:(RestUserSettings *)restUserSettings {
    [self setManagedObjectWithIntermediateObject:restUserSettings];
}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestUserSettings *restUserSettings = (RestUserSettings *) intermediateObject;
    
    self.saveOriginal = [NSNumber numberWithInteger:restUserSettings.saveOriginal];
    self.saveFiltered = [NSNumber numberWithInteger:restUserSettings.saveFiltered];
    self.pushComments = [NSNumber numberWithInteger:restUserSettings.pushComments];
    self.pushPosts = [NSNumber numberWithInteger:restUserSettings.pushPosts];
    self.pushLikes = [NSNumber numberWithInteger:restUserSettings.pushLikes];
    self.pushFriends = [NSNumber numberWithInteger:restUserSettings.pushFriends];
}

- (void)pushToServer:(void (^)(RestUserSettings *restUser))onLoad
             onError:(void (^)(NSError *error))onError {
    RestUserSettings *restUserSettings = [[RestUserSettings alloc] init];
    //endpoint with params 'firstname', 'lastname', 'email', 'location' and 'birthday'
    restUserSettings.saveFiltered = [self.saveFiltered integerValue];
    restUserSettings.saveOriginal = [self.saveOriginal integerValue];
    restUserSettings.pushComments = [self.pushComments integerValue];
    restUserSettings.pushPosts = [self.pushPosts  integerValue];
    restUserSettings.pushLikes = [self.pushLikes integerValue];
    restUserSettings.pushFriends = [self.pushFriends integerValue];
    [restUserSettings pushToServer:onLoad onError:onError];
}

@end
