//
//  ApplicatonNavigationController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicatonNavigationController.h"
#import "UIBarButtonItem+Borderless.h"
@interface ApplicatonNavigationController ()

@end

@implementation ApplicatonNavigationController
@synthesize checkinButton;
@synthesize profileButton;

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
    [self setBackButtonIfNeeded];
	// Do any additional setup after loading the view.
}


- (IBAction)back:(id)sender {
    [self popViewControllerAnimated:YES];
}

- (void)setBackButtonIfNeeded {

    NSLog(@"OBJECT AT 0 IS %@", [self.viewControllers objectAtIndex:0]);
    NSLog(@"TOP VIEW IS %@", self.topViewController);
    NSLog(@"VISIBLE IS %@", self.visibleViewController);
    NSLog(@"SELF IS %@", self);
     
    if ([self.viewControllers objectAtIndex:0] != self.visibleViewController) {
    
    } else {
        NSLog(@"THIS IS THE ROOT VIEW CONTROLLER");
        UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
        UIImage *avatarImage = [UIImage imageNamed:@"profile.png"];
        self.visibleViewController.navigationItem.hidesBackButton = YES;
        self.navigationBar.topItem.rightBarButtonItem = [UIBarButtonItem barItemWithImage:checkinImage target:self.topViewController action:@selector(didCheckIn:)];
        self.navigationBar.topItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:avatarImage target:self.topViewController action:@selector(didSelectSettings:)];

    }
}

- (void)viewDidUnload
{
    [self setCheckinButton:nil];
    [self setProfileButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
