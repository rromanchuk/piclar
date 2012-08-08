
#import "UserShowViewController.h"
#import "Vkontakte.h"
#import "UIBarButtonItem+Borderless.h"
@interface UserShowViewController ()

@end

@implementation UserShowViewController
@synthesize backButton;
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
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIImage *logoutButtonImage = [UIImage imageNamed:@"logout-icon.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *logoutButtonItem = [UIBarButtonItem barItemWithImage:logoutButtonImage target:self.navigationController action:@selector(didLogout:)];
    self.backButton = backButtonItem;
    self.logoutButton = logoutButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
    self.navigationItem.rightBarButtonItem = self.logoutButton;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didLogout:(id)sender {
    NSLog(@"USER CLICKED LOGOUT");
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"DidLogoutNotification" 
     object:self];
}

@end
