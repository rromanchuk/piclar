
@interface BaseNavigationViewController : UINavigationController


@property BOOL wantsBackButtonToDismissModal; 
@property (nonatomic, weak) NSString *notificationOnDismiss;
- (IBAction)dismissModalTo:(id)sender;
@end
