//
//  ApplicatonNavigationController.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseNavigationViewController.h"

@interface ApplicatonNavigationController : BaseNavigationViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;

- (void)setBackButtonIfNeeded;
- (IBAction)back:(id)sender;

@end
