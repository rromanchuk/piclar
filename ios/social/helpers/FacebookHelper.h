//
//  FacebookHelper.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
@protocol FacebookSessionChangedDelegate;

@interface FacebookHelper : NSObject
+ (void)openSession;
+ (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;

@end

@protocol FacebookSessionChangedDelegate <NSObject>

@required
- (void)facebookSessionStateDidChange:(BOOL)success withSession:(FBSession *)session;

@end