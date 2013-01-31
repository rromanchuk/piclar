//
//  WaitForApproveViewController.h
//  Ostronaut
//
//  Created by Ivan Lazarev on 10.10.12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "User+Rest.h"
#import "Logout.h"
#import "ApplicationLifecycleDelegate.h"

@interface WaitForApproveViewController : UIViewController <ApplicationLifecycleDelegate>
@property (weak, nonatomic) id <LogoutDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *textLabelThanks;
@property (weak, nonatomic) IBOutlet UILabel *textLabelWait;

@property (weak, nonatomic) User *currentUser;
@end
