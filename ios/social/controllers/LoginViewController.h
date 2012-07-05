#import <UIKit/UIKit.h>

@protocol VkontakteLoginViewControllerDelegate;
@interface LoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id <VkontakteLoginViewControllerDelegate> delegate;  
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end


@protocol VkontakteLoginViewControllerDelegate <NSObject>
@optional
- (void)authorizationDidSucceedWithToke:(NSString *)accessToken 
                                 userId:(NSString *)userId 
                                expDate:(NSDate *)expDate
                              userEmail:(NSString *)email;
- (void)authorizationDidFailedWithError:(NSError *)error;
- (void)authorizationDidCanceled;
@end
