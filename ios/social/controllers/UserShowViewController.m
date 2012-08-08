
#import "UserShowViewController.h"
#import "Vkontakte.h"
#import "UIBarButtonItem+Borderless.h"
@interface UserShowViewController ()

@end

@implementation UserShowViewController
@synthesize dismissButton;
@synthesize logoutButton;

@synthesize managedObjectContext;

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
    self.navigationItem.hidesBackButton = YES;
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIImage *logoutButtonImage = [UIImage imageNamed:@"logout-icon.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *logoutButtonItem = [UIBarButtonItem barItemWithImage:logoutButtonImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 10;
    self.dismissButton = dismissButtonItem;
    self.logoutButton = logoutButtonItem;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, self.dismissButton, nil]];
    self.navigationItem.rightBarButtonItem = self.logoutButton;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setDismissButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissModal:(id)sender {
    NSLog(@"DISMISSING MODAL");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dismissModal"
     object:self];
}

- (IBAction)didLogout:(id)sender {
    NSLog(@"USER CLICKED LOGOUT");
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"DidLogoutNotification" 
     object:self];
}

@end
