//
//  UserSettings+Rest.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "UserSettings.h"
#import "RestObject.h"
#import "RestUserSettings.h"
#import "User.h"

@interface UserSettings (Rest)

+ (UserSettings *)userSettingsWithRestNotification:(RestUserSettings *)restUserSettings inManagedObjectContext:(NSManagedObjectContext *)context forUser:(User *)user;

- (void)pushToServer:(void (^)(RestUserSettings *restUser))onLoad
             onError:(void (^)(NSString *error))onError;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;
- (void)updateUserSettingsWithRestUserSettings:(RestUserSettings *)restUserSettings;
@end
