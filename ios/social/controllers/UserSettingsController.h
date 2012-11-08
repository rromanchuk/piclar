//
//  UserSettingsController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/10/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TDDatePickerController.h"
#import "Logout.h"
#import "BaseTableView.h"

@interface UserSettingsController : BaseTableView <UITextFieldDelegate>
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *activeTextField;

@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;

@property (weak, nonatomic) IBOutlet UILabel *broadcastVkontakteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *broadcastVkontakteSwitch;
@property (weak, nonatomic) IBOutlet UILabel *saveFilteredImagelLabel;
@property (weak, nonatomic) IBOutlet UILabel *saveOriginalImageLabel;
@property (weak, nonatomic) IBOutlet UISwitch *saveFilteredImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveOriginalImageSwitch;
@property (strong, nonatomic) TDDatePickerController *datePickerController;
@property (weak) id <LogoutDelegate> delegate;

- (IBAction)pushUserSettings:(id)sender;
- (IBAction)didLogout:(id)sender;
- (IBAction)didTapBirthday:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)showPushSettings:(id)sender;

-(void)datePickerSetDate:(TDDatePickerController*)viewController;
-(void)datePickerClearDate:(TDDatePickerController*)viewController;
-(void)datePickerCancel:(TDDatePickerController*)viewController;
@end

