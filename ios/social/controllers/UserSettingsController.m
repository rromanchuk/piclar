//
//  UserSettingsController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/10/12.
//
//

#import "UserSettingsController.h"

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
