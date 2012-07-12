
@interface BaseNavigationViewController : UINavigationController

@property (nonatomic, weak) IBOutlet UIBarButtonItem *profileButton; 
@property (nonatomic, weak) IBOutlet UIBarButtonItem *checkinButton;

- (IBAction)didCheckIn:(id)sender;
- (IBAction)didSelectSettings:(id)sender;

@end
