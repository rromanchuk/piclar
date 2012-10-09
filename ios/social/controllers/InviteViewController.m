//
//  InviteViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/2/12.
//
//

#import "InviteViewController.h"

@interface InviteViewController ()

@end

@implementation InviteViewController
@synthesize managedObjectContext;
@synthesize navigation;

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
    UIImage *backImage = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *backButton = [UIBarButtonItem barItemWithImage:backImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *leftFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixed.width = 5;
    self.navigation.topItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButton, nil];
    self.navigation.topItem.hidesBackButton = NO;
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEnterCodeLabel:nil];
    [self setCodeTextField:nil];
    [self setEnterButton:nil];
    [self setCheckinLabel:nil];
    [self setCheckinButton:nil];
    [self setNavigation:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (IBAction)didLogout:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didCreateCheckinButtonTouched:(id)sender {
    [self didFinishCheckingIn];
}

- (IBAction)didCodeButtonTouched:(id)sender {
    [self.currentUser checkInvitationCode:self.codeTextField.text onSuccess:^(void) {
        DLog(@"CODE IS OK")
        [self.delegate didEnterValidInvitationCode];
        [self dismissModalViewControllerAnimated:YES];
        
    } onError:^(void) {
        DLog(@"CODE IS BAD")
        
    }];
    
}


# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
}

@end
