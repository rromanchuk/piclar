//
//  UserSettingsController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/10/12.
//
//

#import "UserSettingsController.h"
#import "BaseView.h"
@interface UserSettingsController ()

@end

@implementation UserSettingsController

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
    self.title = NSLocalizedString(@"SETTINGS", "User settings page title");
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil ];
    
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    
    self.emailTextField.text = self.user.email;
    //self.birthdayTextField.textLabel = self.user.
    self.locationTextField.text = self.user.location;
    self.firstNameTextField.text = self.user.firstname;
    self.lastNameTextField.text = self.user.lastname;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setFirstNameTextField:nil];
    [self setLastNameTextField:nil];
    [self setLocationTextField:nil];
    [self setBirthdayTextField:nil];
    [self setEmailTextField:nil];
    [self setBroadcastVkontakteSwitch:nil];
    [self setSaveFilteredImageSwitch:nil];
    [self setSaveOriginalImageSwitch:nil];
    [self setBirthdayTextField:nil];
    [self setEmailTextField:nil];
    [super viewDidUnload];
}
@end
