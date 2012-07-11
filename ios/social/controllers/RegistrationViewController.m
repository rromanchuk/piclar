//
//  RegistrationViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationViewController.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize registrationLabel;
@synthesize loginButton;

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
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL", @"Placeholder for login");
    self.passwordTextField.placeholder = NSLocalizedString(@"PASSWORD", @"Placeholder for login");
    self.registrationLabel.text = NSLocalizedString(@"REGISTRATION", @"Registration text");
    self.loginButton.titleLabel.text = NSLocalizedString(@"LOGIN", @"Login button text");
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setRegistrationLabel:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
