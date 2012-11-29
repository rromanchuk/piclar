//
//  UserSettings.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 11/27/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserSettings : NSManagedObject

@property (nonatomic, retain) NSString * fbToken;
@property (nonatomic, retain) NSNumber * saveFiltered;
@property (nonatomic, retain) NSNumber * saveOriginal;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSNumber * vkShare;
@property (nonatomic, retain) NSString * vkToken;
@property (nonatomic, retain) User *user;

@end
