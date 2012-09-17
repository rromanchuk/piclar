//
//  UserSettingsController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/10/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserSettingsController : UITableViewController <UITextFieldDelegate>
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UISwitch *broadcastVkontakteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveFilteredImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveOriginalImageSwitch;

-(IBAction)pushUserSettings:(id)sender;
- (IBAction)didLogout:(id)sender;
@end
