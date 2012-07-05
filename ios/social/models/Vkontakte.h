
#import <Foundation/Foundation.h>
#import "LoginViewController.h"

@protocol VkontakteDelegate;
@interface Vkontakte : NSObject <LoginViewControllerDelegate> {
    NSString *accessToken;
    NSDate *expirationDate;
    NSString *userId;
    NSString *email;
    
    BOOL _isCaptcha;
}
@property (nonatomic, weak) id <VkontakteDelegate> delegate;

+ (id)sharedInstance;
- (BOOL)isAuthorized;
- (void)authenticate;
- (void)logout;
- (void)getUserInfo;
@end


@protocol VkontakteDelegate <NSObject>
@required
- (void)vkontakteDidFailedWithError:(NSError *)error;
- (void)showVkontakteAuthController:(UIViewController *)controller;
- (void)vkontakteAuthControllerDidCancelled; 

@optional
- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte;
- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte;
- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info;
- (void)vkontakteDidFinishPostingToWall:(NSDictionary *)responce;
@end