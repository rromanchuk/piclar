
#import "UserShowViewController.h"
#import "Vkontakte.h"
@interface UserShowViewController ()

@end

@implementation UserShowViewController

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

- (IBAction)didLogout:(id)sender {
    [[Vkontakte sharedInstance] logout];
    NSLog(@"USER CLICKED LOGOUT");
    [self dismissModalViewControllerAnimated:NO];
}

@end
