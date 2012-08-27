//
//  UserRequestEmailViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import "UserRequestEmailViewController.h"

@interface UserRequestEmailViewController ()

@end

@implementation UserRequestEmailViewController
@synthesize emailFromVk;
@synthesize emailDescriptionLabel;
@synthesize emailTextField;
@synthesize enterButton;
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
    [self.enterButton setTitle:NSLocalizedString(@"LOGIN", @"login button text") forState:UIControlStateNormal];
    [self.enterButton setTitle:NSLocalizedString(@"LOGIN", @"login button text") forState:UIControlStateHighlighted];
    self.emailTextField.placeholder = NSLocalizedString(@"ENTER_EMAIL", @"Placeholder for the email textfield");
    if (self.emailFromVk.length > 0) 
        self.emailTextField.text = self.emailFromVk;
   	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailDescriptionLabel:nil];
    [self setEmailTextField:nil];
    [self setEnterButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didClickFinished:(id)sender {
    [self.delegate didFinishRequestingEmail:self.emailTextField.text];
}

@end
