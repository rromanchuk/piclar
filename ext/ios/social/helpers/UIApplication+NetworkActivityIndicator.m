#import "UIApplication+NetworkActivityIndicator.h"
static int networkActivityCount = 0;

@implementation UIApplication (NetworkActivityIndicator)
- (void)showNetworkActivityIndicator 
{      
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(showNetworkActivityIndicator)
                               withObject:nil
                            waitUntilDone:NO];
        return;
    }
        
    
    if (!networkActivityCount)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    networkActivityCount++;
}

- (void)hideNetworkActivityIndicator
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(hideNetworkActivityIndicator)
                               withObject:nil
                            waitUntilDone:NO];
        return;
    }
            
    networkActivityCount = MAX(networkActivityCount - 1, 0);
    
    if (!networkActivityCount)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

@end
