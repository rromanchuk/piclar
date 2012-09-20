//
//  UserSettingsController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/10/12.
//
//

#import "UserSettingsController.h"
#import "BaseView.h"
#import "RestUserSettings.h"
#import "UserSettings+Rest.h"
#import "User+Rest.h"
#import "TDSemiModal.h"

@interface UserSettingsController ()
@property NSString *originalText;
@end

@implementation UserSettingsController
@synthesize user;
@synthesize originalText;
@synthesize datePickerController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datePickerController = [[TDDatePickerController alloc]
                                 initWithNibName:@"TDDatePickerController"
                                 bundle:nil];
    self.datePickerController.datePicker.date = self.user.birthday;
    
    self.title = NSLocalizedString(@"SETTINGS", "User settings page title");
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIImage *logoutImage = [UIImage imageNamed:@"logout-icon.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *logoutButtonItem = [UIBarButtonItem barItemWithImage:logoutImage target:self action:@selector(didLogout:)];

    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil ];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, logoutButtonItem, nil];
    
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL", "email placeholder");
    self.emailTextField.text = self.user.email;
    
    [self setBirthday];
    
    
    self.locationTextField.placeholder = NSLocalizedString(@"LOCATION", "email placeholder");
    self.locationTextField.text = self.user.location;
    
    self.firstNameTextField.placeholder =  NSLocalizedString(@"FIRST_NAME", "email placeholder");
    self.firstNameTextField.text = self.user.firstname;
    
    self.lastNameTextField.placeholder = NSLocalizedString(@"LAST_NAME", "email placeholder");
    self.lastNameTextField.text = self.user.lastname;
    
    self.saveOriginalImageSwitch.enabled = [self.user.settings.saveOriginal boolValue];
    self.saveFilteredImageSwitch.enabled = [self.user.settings.saveFiltered boolValue];
    self.broadcastVkontakteSwitch.enabled = [self.user.settings.vkShare boolValue];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DatePicker"]) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchResults];
}

- (void)viewDidUnload {
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setLocationTextField:nil];
    [self setEmailTextField:nil];
    [self setBroadcastVkontakteSwitch:nil];
    [self setSaveFilteredImageSwitch:nil];
    [self setSaveOriginalImageSwitch:nil];
    [self setEmailTextField:nil];
    [self setBirthdayButton:nil];
    [super viewDidUnload];
}

- (void)fetchResults {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"loading hud")];
    [RestUserSettings load:^(RestUserSettings *restUserSettings) {
        if (self.user.settings) {
            [self.user.settings updateUserSettingsWithRestUserSettings:restUserSettings];
        } else {
            [UserSettings userSettingsWithRestNotification:restUserSettings inManagedObjectContext:self.managedObjectContext forUser:self.user];
        }
        self.saveOriginalImageSwitch.on = [self.user.settings.saveOriginal boolValue];
        self.saveFilteredImageSwitch.on = [self.user.settings.saveFiltered boolValue];
        self.broadcastVkontakteSwitch.on = [self.user.settings.vkShare boolValue];
        [SVProgressHUD dismiss];
    } onError:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UNABLE_TO_LOAD_SETTINGS_FROM_SERVER", @"Cant")];
    }];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self pushUser:textField];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.originalText = textField.text;
}

- (IBAction)pushUser:(id)sender {
    if ([((UITextField *)sender).text isEqualToString:self.originalText])
        return;
    
    
    if (sender == self.firstNameTextField) {
        self.user.firstname = ((UITextField *)sender).text;
    } else if (sender == self.lastNameTextField) {
        self.user.lastname = ((UITextField *)sender).text;
    } else if (sender == self.locationTextField) {
        self.user.location = ((UITextField *)sender).text;
    } else if (sender == self.emailTextField) {
        self.user.email = ((UITextField *)sender).text;
    }
    
    [self.user pushToServer:^(RestUser *restUser) {
        
    } onError:^(NSString *error) {
        ((UITextField *)sender).text = self.originalText;
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UNABLE_TO_UPDATE_SETTINGS", @"Server error, wasn't able to update settings")];
    }];
}

-(IBAction)pushUserSettings:(id)sender {
    if (sender == self.broadcastVkontakteSwitch) {
        DLog(@"broad cast vk %@ %@", [NSNumber numberWithBool:self.broadcastVkontakteSwitch.on], [NSNumber numberWithBool:((UISwitch *)sender).on]);
        self.user.settings.vkShare =  [NSNumber numberWithBool:self.broadcastVkontakteSwitch.on];
    } else if (sender == self.saveFilteredImageSwitch) {
        self.user.settings.saveFiltered =  [NSNumber numberWithBool:self.saveFilteredImageSwitch.on];
    } else if (sender == self.saveOriginalImageSwitch) {
        self.user.settings.saveOriginal =  [NSNumber numberWithBool:self.saveOriginalImageSwitch.on];
    } 
    
    [self.user.settings pushToServer:^(RestUserSettings *restUser) {
        
    } onError:^(NSString *error) {
        ((UISwitch *)sender).enabled = !((UISwitch *)sender).on;
        [SVProgressHUD showErrorWithStatus:@"Could not update settings. :("];
    }];
}

- (IBAction)didLogout:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DidLogoutNotification"
     object:self];
}

- (IBAction)didTapBirthday:(id)sender {
    self.datePickerController.delegate = self;
    [self.parentViewController presentSemiModalViewController:self.datePickerController];
    //[self presentSemiModalViewController:self.datePickerController];
}

- (void)setBirthday {
    if(self.user.birthday) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        NSString *dateString = [dateFormatter stringFromDate:self.user.birthday];
        [self.birthdayButton setTitle:dateString forState:UIControlStateNormal];
    } else {
        [self.birthdayButton setTitle:NSLocalizedString(@"TAP_TO_SET_BIRTHDAY", @"") forState:UIControlStateNormal];
    }
}

- (void)datePickerSetDate:(TDDatePickerController *)viewController {
    DLog(@"IN SELECT");
    [self.parentViewController dismissSemiModalViewController:self.datePickerController];
    NSDate *oldDate = self.user.birthday;
    self.user.birthday = viewController.datePicker.date;
    
    [self.user pushToServer:^(RestUser *restUser) {
        [self setBirthday];
    } onError:^(NSString *error) {
        self.user.birthday = oldDate;
        [self setBirthday];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UNABLE_TO_UPDATE_SETTINGS", @"Server error, wasn't able to update settings")];
    }];
}

- (void)datePickerClearDate:(TDDatePickerController *)viewController {
    DLog(@"IN CLEARDATE");
    viewController.datePicker.date = self.user.birthday;

}

- (void)datePickerCancel:(TDDatePickerController *)viewController {
    DLog(@"IN CANCEL");
    [self.parentViewController dismissSemiModalViewController:self.datePickerController];
}

@end
