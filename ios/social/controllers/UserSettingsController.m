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
#import "AppDelegate.h"
#import "UAPush.h"

@interface UserSettingsController ()
@property NSString *originalText;
@property BOOL isLoggingOut; 
@end

@implementation UserSettingsController
@synthesize user;
@synthesize originalText;
@synthesize datePickerController;
@synthesize isLoggingOut;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        needsBackButton = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datePickerController = [[TDDatePickerController alloc]
                                 initWithNibName:@"TDDatePickerController"
                                 bundle:nil];
    self.datePickerController.delegate = self;
    self.datePickerController.datePicker.date = self.user.birthday;
    
    self.title = NSLocalizedString(@"SETTINGS", "User settings page title");
    
    

    self.saveFilteredImagelLabel.text = NSLocalizedString(@"FILTERED", nil);
    self.saveOriginalImageLabel.text = NSLocalizedString(@"ORIGINAL", nil);
    self.emailTextField.placeholder = NSLocalizedString(@"EMAIL", "email placeholder");
    self.emailTextField.text = self.user.email;
    [self setBirthday];
    
    
    self.locationTextField.placeholder = NSLocalizedString(@"LOCATION", "email placeholder");
    self.locationTextField.text = self.user.location;
    
    self.firstNameTextField.placeholder =  NSLocalizedString(@"FIRST_NAME", "email placeholder");
    self.firstNameTextField.text = self.user.firstname;
    
    self.lastNameTextField.placeholder = NSLocalizedString(@"LAST_NAME", "email placeholder");
    self.lastNameTextField.text = self.user.lastname;
    
    self.saveOriginalImageSwitch.on = [self.user.settings.saveOriginal boolValue];
    self.saveFilteredImageSwitch.on = [self.user.settings.saveFiltered boolValue];
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.delegate = sharedAppDelegate;
    
    
    self.pushNewFollowersLabel.text = NSLocalizedString(@"PUSH_NEW_FOLLOWER", @"push new followers");
    self.pushNewCommentsLabel.text = NSLocalizedString(@"PUSH_COMMENTS", @"push new comments");
    self.pushPostsFromFriendsLabel.text = NSLocalizedString(@"PUSH_POSTS", @"push posts from friends");
    self.pushLikesFromFriendsLabel.text = NSLocalizedString(@"PUSH_LIKES", @"push like actions from friends");
    self.logoutCell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.logoutButton setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
    
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!isLoggingOut) 
        [self pushUser:self.activeTextField];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    needsBackButton = YES;
    [self fetchResults];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"SCREEN_USER_SETTINGS"];
}

- (void)viewDidUnload {
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setLocationTextField:nil];
    [self setEmailTextField:nil];
    [self setSaveFilteredImageSwitch:nil];
    [self setSaveOriginalImageSwitch:nil];
    [self setEmailTextField:nil];
    [self setBirthdayButton:nil];
    [self setSaveFilteredImagelLabel:nil];
    [self setSaveOriginalImageLabel:nil];
    [self setLogoutButton:nil];
    [self setLogoutCell:nil];
    [self setPushNewCommentsSwitch:nil];
    [self setPushPostsFromFriendsLabel:nil];
    [self setPushPostsFromFriendsSwitch:nil];
    [self setPushLikesFromFriendsLabel:nil];
    [self setPushLikesFromFriendsSwitch:nil];
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
        self.pushNewCommentsSwitch.on = [self.user.settings.pushComments boolValue];
        self.pushNewFollowersSwitch.on = [self.user.settings.pushFriends boolValue];
        self.pushPostsFromFriendsSwitch.on = [self.user.settings.pushPosts boolValue];
        self.pushLikesFromFriendsSwitch.on = [self.user.settings.pushLikes boolValue];
        [SVProgressHUD dismiss];
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.tableView.frame.size.width, 15)];
    
    [view addSubview:sectionHeader];
    switch (section) {
        case 0:
            sectionHeader.text = NSLocalizedString(@"PHOTO_SETTINGS", nil);
            break;
        case 1:
            sectionHeader.text = NSLocalizedString(@"PERSONAL", nil);
            break;
        case 2:
            sectionHeader.text = NSLocalizedString(@"PUSH_SETTINGS", nil);
            break;
        default:
            break;
    }
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    sectionHeader.textColor = RGBCOLOR(93, 93, 93);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self pushUser:textField];
    DLog(@"did end editing");
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.originalText = textField.text;
    self.activeTextField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self pushUser:textField];
    return NO;
}

- (IBAction)hideKeyboard:(id)sender {
    DLog(@"in hide keyboard");
    [self pushUser:self.activeTextField];
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;
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
        
    } onError:^(NSError *error) {
        ((UITextField *)sender).text = self.originalText;
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UNABLE_TO_UPDATE_SETTINGS", @"Server error, wasn't able to update settings")];
    }];
}

- (IBAction)pushUserSettings:(id)sender {
   if (sender == self.saveFilteredImageSwitch) {
        self.user.settings.saveFiltered =  [NSNumber numberWithBool:self.saveFilteredImageSwitch.on];
    } else if (sender == self.saveOriginalImageSwitch) {
        self.user.settings.saveOriginal =  [NSNumber numberWithBool:self.saveOriginalImageSwitch.on];
    } else if (sender == self.pushNewCommentsSwitch) {
        self.user.settings.pushComments = [NSNumber numberWithBool:self.pushNewCommentsSwitch.on];
    } else if (sender == self.pushNewFollowersSwitch) {
        self.user.settings.pushFriends = [NSNumber numberWithBool:self.pushNewFollowersSwitch.on];
    } else if (sender == self.pushPostsFromFriendsSwitch) {
        self.user.settings.pushPosts = [NSNumber numberWithBool:self.pushPostsFromFriendsSwitch.on];
    } else if (sender == self.pushLikesFromFriendsSwitch) {
        self.user.settings.pushLikes
        = [NSNumber numberWithBool:self.pushLikesFromFriendsSwitch.on];
    }
    
    [self.user.settings pushToServer:^(RestUserSettings *restUser) {
        
    } onError:^(NSError *error) {
        ((UISwitch *)sender).on = !((UISwitch *)sender).on;
        [SVProgressHUD showErrorWithStatus:@"Could not update settings. :("];
    }];
}

- (IBAction)didLogout:(id)sender {
    DLog(@"did logout");
    isLoggingOut = YES;
    [self.delegate didLogout];
}

- (IBAction)didTapBirthday:(id)sender {
    [self.activeTextField resignFirstResponder];
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
    } onError:^(NSError *error) {
        self.user.birthday = oldDate;
        [self setBirthday];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"UNABLE_TO_UPDATE_SETTINGS", @"Server error, wasn't able to update settings")];
    }];
}

- (void)datePickerClearDate:(TDDatePickerController *)viewController {
    DLog(@"IN CLEARDATE");
    NSDate *defaultDate;
    if (self.user.birthday) {
        defaultDate = self.user.birthday;
    } else {
        defaultDate = [NSDate distantPast];
    }
    viewController.datePicker.date = defaultDate;

}

- (void)datePickerCancel:(TDDatePickerController *)viewController {
    DLog(@"IN CANCEL");
    [self.parentViewController dismissSemiModalViewController:self.datePickerController];
}

@end
