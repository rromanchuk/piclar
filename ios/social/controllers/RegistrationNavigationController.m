//
//  RegistrationNavigationController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationNavigationController.h"
#import "UIBarButtonItem+Borderless.h"

@interface RegistrationNavigationController ()

@end

@implementation RegistrationNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notificationOnDismiss = @"DidLogoutNotification";
    UIImage *backbuttonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 10;
    //[self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, [UIBarButtonItem barItemWithImage:backbuttonImage target:self action:@selector(dismissModalTo:)], nil]];
    //self.navigationBar.topItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:backbuttonImage target:self action:@selector(dismissModalTo:)];
    self.navigationBar.topItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, [UIBarButtonItem barItemWithImage:backbuttonImage target:self action:@selector(dismissModalTo:)], nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
