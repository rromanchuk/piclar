//
//  InviteViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/2/12.
//
//

#import "InviteViewController.h"

@interface InviteViewController ()
- (void)processCodeEnter;
@end

@implementation InviteViewController
@synthesize managedObjectContext;
@synthesize errorLabel;


- (void)viewDidLoad
{

    [super viewDidLoad];
    UIImage *backImage = [UIImage imageNamed:@"dismiss.png"];
    
    UIBarButtonItem *backButton = [UIBarButtonItem barItemWithImage:backImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *leftFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButton, nil];
    self.title = NSLocalizedString(@"NEED_INVITATION_CODE", @"Need invitation code");
    // Do any additional setup after loading the view.
    self.codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.codeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.codeTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.codeTextField.returnKeyType = UIReturnKeySend;
    self.codeTextField.delegate = self;
    
    self.enterCodeLabel.text = NSLocalizedString(@"ENTER_INVITATION_CODE", @"Enter invitation code");
    [self.enterButton setTitle:NSLocalizedString(@"SEND_CODE", @"Send invitation code") forState:UIControlStateNormal];
    [self.enterButton setTitle:NSLocalizedString(@"SEND_CODE", @"Send invitation code") forState:UIControlStateSelected];


    self.errorLabel.text = NSLocalizedString(@"INVALID_CODE", @"Invalid code");
    self.codeTextField.placeholder = NSLocalizedString(@"CODE_PLACEHOLDER", @"Code");
    self.checkinLabel.text = NSLocalizedString(@"CHECKIN_TO_INVITE", @"Do checkin to invite");
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
    [self setErrorLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createCheckin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.currentUser = self.currentUser;
    }
    
}

- (void)processCodeEnter {
    [self.currentUser checkInvitationCode:self.codeTextField.text onSuccess:^(void) {
        DLog(@"CODE IS OK")
        [self.delegate didEnterValidInvitationCode];
        [self dismissModalViewControllerAnimated:YES];
        
    } onError:^(void) {
        DLog(@"CODE IS BAD")
        [self.errorLabel setHidden:NO];
        
    }];
    
}

- (IBAction)didLogout:(id)sender {
    [self.delegate didLogout];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didCreateCheckinButtonTouched:(id)sender {
    [self performSegueWithIdentifier:@"createCheckin" sender:self];
}

- (IBAction)didCodeButtonTouched:(id)sender {
    [self processCodeEnter];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self processCodeEnter];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.errorLabel setHidden:YES];
    return YES;
}



# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    DLog(@"CHECKIN DONE");
    [self.currentUser updateFromServer:^(void) {
        [self dismissModalViewControllerAnimated:NO];
        [self dismissModalViewControllerAnimated:YES];
    }];
}

- (void)didCanceledCheckingIn {
    DLog(@"CHECKIN CANCELED");
    [self dismissModalViewControllerAnimated:YES];
}

@end
