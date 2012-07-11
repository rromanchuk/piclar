
#import "BaseNavigationViewController.h"
#import "UIBarButtonItem+Borderless.h"

@interface BaseNavigationViewController ()

@end

@implementation BaseNavigationViewController
@synthesize profileButton; 
@synthesize checkinButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"]
                                 forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:20.0], UITextAttributeFont, RGBACOLOR(204.0, 204.0, 204.0, 1.0), UITextAttributeTextColor, nil];
    UIImage *gearImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *avatarImage = [UIImage imageNamed:@"profile.png"];
    self.checkinButton = [UIBarButtonItem barItemWithImage:gearImage target:self action:@selector(didCheckIn:)];
    self.profileButton = [UIBarButtonItem barItemWithImage:avatarImage target:self action:@selector(didSelectSettings:)];
    self.navigationBar.topItem.rightBarButtonItem = self.checkinButton;
    self.navigationBar.topItem.leftBarButtonItem = self.profileButton;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didCheckIn:(id)sender {
    NSLog(@"did checkin");
    
}

- (IBAction)didSelectSettings:(id)sender {
    NSLog(@"did select settings");
    [self performSegueWithIdentifier:@"UserShow" sender:self];
}

@end
