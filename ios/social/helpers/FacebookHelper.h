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

@property (weak, nonatomic) id <FacebookSessionChangedDelegate> delegate;

- (void)openSession;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;

+ (void)uploadPhotoToFacebook:(UIImage *)image;
- (BOOL)canPublishActions;
- (void)prepareForPublishing;
- (void)syncAccount;
+ (FacebookHelper *)shared;


@end

@protocol FacebookSessionChangedDelegate <NSObject>

@required
- (void)facebookSessionStateDidChange:(BOOL)success withSession:(FBSession *)session;

@end