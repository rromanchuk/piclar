
#import "UserShowViewController.h"
#import "Vkontakte.h"
#import "UIBarButtonItem+Borderless.h"
#import "RestUser.h"
@interface UserShowViewController ()

@end

@implementation UserShowViewController
@synthesize dismissButton;
@synthesize logoutButton;
@synthesize managedObjectContext;
@synthesize user;

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

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriends];
    [self fetchResults];
    self.title = NSLocalizedString(@"PROFILE", "User's profile page title");
}
- (void)viewDidUnload
{
    [self setDismissButton:nil];
    [self setUserProfilePhotoViewHeader:nil];
    [self setUserNameHeaderLabel:nil];
    [self setUserLocationHeaderLabel:nil];
    [self setUserFollowingHeaderButton:nil];
    [self setUserMutualFollowingHeaderButton:nil];
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

-(void) fetchResults {
    
}

- (void)fetchFriends {
    [RestUser loadFollowing:^(NSSet *users) {
        [self.user addFollowing:users];
    } onError:^(NSString *error) {
        //
    }];
    
    [RestUser loadFollowers:^(NSSet *users) {
        [self.user addFollowers:users];
    } onError:^(NSString *error) {
        NSLog(@"");
    }];
    
}

@end
