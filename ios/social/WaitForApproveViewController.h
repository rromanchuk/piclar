//
//  WaitForApproveViewController.h
//  Ostronaut
//
//  Created by Ivan Lazarev on 10.10.12.
//
//

#import <UIKit/UIKit.h>
#import "Logout.h"

@interface WaitForApproveViewController : UIViewController
@property (weak, nonatomic) id <LogoutDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *textLabelThanks;
@property (weak, nonatomic) IBOutlet UILabel *textLabelWait;
@end
