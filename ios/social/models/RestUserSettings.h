//
//  RestUserSettings.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/13/12.
//
//

#import "RestObject.h"

@interface RestUserSettings : RestObject
@property NSInteger saveOriginal;
@property NSInteger saveFiltered;
@property NSInteger pushFriends;
@property NSInteger pushPosts;
@property NSInteger pushComments;
@property NSInteger pushLikes;


+ (NSDictionary *)mapping;

+ (void)load:(void (^)(RestUserSettings *restUserSettings))onLoad
     onError:(void (^)(NSError *error))onError;

- (void)pushToServer:(void (^)(RestUserSettings *restUserSettings))onLoad
             onError:(void (^)(NSError *error))onError;

@end

