//
//  UserRequestEmailViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import <UIKit/UIKit.h>
#import "Logout.h"

@protocol RequestEmailDelegate;

@interface UserRequestEmailViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) id <RequestEmailDelegate, LogoutDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)didClickFinished:(id)sender;
@end

@protocol RequestEmailDelegate <NSObject>
@required
- (void)didFinishRequestingEmail:(NSString *)email;

@end