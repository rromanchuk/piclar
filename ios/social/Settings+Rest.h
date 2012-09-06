//
//  Settings+Rest.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/6/12.
//
//

#import "Settings.h"
#import "RestSettings.h"
@interface Settings (Rest)
+ (Settings *)settingsItemWithRestSettings:(RestSettings *)restSettingsItem
                inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

@end
