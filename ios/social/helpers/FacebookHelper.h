//
//  FacebookHelper.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import <Foundation/Foundation.h>
#import "Facebook.h"
#import "RestUser.h"
@protocol FacebookHelperDelegate;

@interface FacebookHelper : NSObject <FBRequestDelegate>

@property (weak, nonatomic) id <FacebookHelperDelegate> delegate;
@property (strong, nonatomic) Facebook *facebook;

- (void)login;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;

- (void)uploadPhotoToFacebook:(UIImage *)image;
- (BOOL)canPublishActions;
- (void)prepareForPublishing;
- (void)syncAccount;
+ (FacebookHelper *)shared;


@end

@protocol FacebookHelperDelegate <NSObject>

@required
- (void)fbDidLogin:(RestUser *)restUser;
- (void)fbDidFailLogin;
- (void)fbSessionValid;
@end