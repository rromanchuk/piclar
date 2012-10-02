//
//  InviteViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/2/12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    PersonStatusTypeActive,
    PersonStatusTypeWaitingForInvite
    
} PersonStatusType;


@interface InviteViewController : UIViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@property (weak, nonatomic) IBOutlet UILabel *enterCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UILabel *checkinLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;

@end

@protocol InvitationDelegate <NSObject>

@optional
- (void)didEnterValidInvitationCode;
@end