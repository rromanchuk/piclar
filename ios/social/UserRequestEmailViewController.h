//
//  UserRequestEmailViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/27/12.
//
//

#import <UIKit/UIKit.h>

@protocol RequestEmailDelegate;

@interface UserRequestEmailViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSString *emailFromVk;
@property (weak, nonatomic) IBOutlet UILabel *emailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) id <RequestEmailDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)didClickFinished:(id)sender;
@end

@protocol RequestEmailDelegate <NSObject>
@required
- (void)didFinishRequestingEmail:(NSString *)email;

@end