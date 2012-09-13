//
//  UserSettings.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserSettings : NSManagedObject

@property (nonatomic, retain) NSNumber * vkShare;
@property (nonatomic, retain) NSNumber * saveOriginal;
@property (nonatomic, retain) NSNumber * saveFiltered;
@property (nonatomic, retain) User *user;

@end
