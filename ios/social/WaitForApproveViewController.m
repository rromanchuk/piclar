//
//  WaitForApproveViewController.m
//  Ostronaut
//
//  Created by Ivan Lazarev on 10.10.12.
//
//

#import "WaitForApproveViewController.h"
#import "AppDelegate.h"

@interface WaitForApproveViewController ()

@end

@implementation WaitForApproveViewController

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
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).delegate = self;
    
    UIImage *backImage = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *backButton = [UIBarButtonItem barItemWithImage:backImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *leftFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButton, nil];
    self.title = NSLocalizedString(@"WAIT_FOR_APPROVE", @"You should wait for approve");
    self.textLabelThanks.text= NSLocalizedString(@"WAIT_FOR_APPROVE_THANSK_FOR_PHOTO", @"Thanks for your photo");
    self.textLabelWait.text = NSLocalizedString(@"WAIT_FOR_APPROVE_WAIT", @"Wait for approve");
    // Do any additional setup after loading the view.
    [self.currentUser addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    // too expensive listener, change it to more specific
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForUserStatusUpdate) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

}

- (void)checkForUserStatusUpdate {
    if (self.currentUser.registrationStatus.intValue != 11) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)didLogout:(id)sender {
    [self.delegate didLogout];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [self setTextLabelThanks:nil];
    [self setTextLabelWait:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ApplicationLifecycleDelegate
- (void)applicationWillExit {
    
}
- (void)applicationWillWillStart {
    DLog(@"WILL START");
    [self.currentUser updateFromServer:^(void) {
        DLog(@"LOADED");
        if (self.currentUser.registrationStatus.intValue != 11) {
            
            [self dismissModalViewControllerAnimated:YES];
        }
    }];
}

@end
