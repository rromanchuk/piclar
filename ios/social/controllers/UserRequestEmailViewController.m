//
//  UserRequestEmailViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import "UserRequestEmailViewController.h"
#import "Utils.h"
@interface UserRequestEmailViewController ()
- (void) processEmailEnter;
@end

@implementation UserRequestEmailViewController
@synthesize errorLabel;
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
    [self.enterButton setTitle:NSLocalizedString(@"SUBMIT_EMAIL", @"login button text") forState:UIControlStateNormal];
    [self.enterButton setTitle:NSLocalizedString(@"SUBMIT_EMAIL", @"login button text") forState:UIControlStateHighlighted];
    self.emailTextField.placeholder = NSLocalizedString(@"ENTER_EMAIL", @"Placeholder for the email textfield");

    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.returnKeyType = UIReturnKeySend;
    self.emailTextField.delegate = self;

    self.errorLabel.text = NSLocalizedString(@"EMAIL_NOT_VALID", @"Error text when the email isn't in valid form");
    //self.emailDescriptionLabel.text = NSLocalizedString(@"REQUEST_EMAIL_DESCRIPTION", @"Description of why we need email");
    
    UIImage *backImage = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *backButton = [UIBarButtonItem barItemWithImage:backImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *leftFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButton, nil];
    self.title = NSLocalizedString(@"NEED_ENTER_EMAIL", @"Need enter email");
    self.enterEmailLabel.text = NSLocalizedString(@"ENTER_EMAIL_LABEL", @"Need enter email label");

}

- (IBAction)didLogout:(id)sender {
    [self.delegate didLogout];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    //[self setEmailDescriptionLabel:nil];
    [self setEmailTextField:nil];
    [self setEnterButton:nil];
    [self setErrorLabel:nil];
    [self setEnterEmailLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"SCREEN_REQUEST_USER_EMAIL"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) processEmailEnter {
    if ([Utils NSStringIsValidEmail:self.emailTextField.text]){
        self.errorLabel.hidden = YES;
        [self.delegate didFinishRequestingEmail:self.emailTextField.text];
    } else {
        self.errorLabel.hidden = NO;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self processEmailEnter];
    return YES;
}

- (IBAction)didClickFinished:(id)sender {
    [self processEmailEnter];
    
}

- (IBAction)hideKeyboard:(id)sender {
    [self.emailTextField resignFirstResponder];
}


@end
