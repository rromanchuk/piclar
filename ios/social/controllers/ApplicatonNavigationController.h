//
//  ApplicatonNavigationController.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "NotificationHandler.h"
#import "NotificationBanner.h"
@interface ApplicatonNavigationController : BaseNavigationViewController <NotificationDisplayModalDelegate>

@property (strong, nonatomic) NotificationBanner *notificationBanner;
- (IBAction)back:(id)sender;

@end
