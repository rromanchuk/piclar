#import <Foundation/Foundation.h>

@protocol LogoutDelegate <NSObject>
@required
- (void)didLogout;

@end
