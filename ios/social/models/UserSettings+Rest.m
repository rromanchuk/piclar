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


- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestUserSettings *restUserSettings = (RestUserSettings *) intermediateObject;
    
    self.vkShare = [NSNumber numberWithInteger:restUserSettings.vkShare];
    self.saveOriginal = [NSNumber numberWithInteger:restUserSettings.saveOriginal];
    self.saveFiltered = [NSNumber numberWithInteger:restUserSettings.saveFiltered];
}

@end
