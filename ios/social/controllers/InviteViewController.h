//
//  InviteViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/2/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "PhotoNewViewController.h"
#import "Logout.h"

typedef enum {
    PersonStatusTypeActive,
    PersonStatusTypeWaitingForInvite
    
} PersonStatusType;

@protocol InvitationDelegate <NSObject>

@optional
- (void)didEnterValidInvitationCode;
@end



@interface InviteViewController : UIViewController <CreateCheckinDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UILabel *checkinLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@property (weak, nonatomic) id <InvitationDelegate, LogoutDelegate> delegate;
@property (weak, nonatomic) User *currentUser;

@end



