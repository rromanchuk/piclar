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
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *avatarImage = [UIImage imageNamed:@"profile.png"];
    
    self.profileButton = [UIBarButtonItem barItemWithImage:avatarImage target:self action:@selector(didSelectSettings:)];
    self.checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    
    self.navigationBar.topItem.rightBarButtonItem = self.checkinButton; 
    self.navigationBar.topItem.leftBarButtonItem = self.profileButton;

	// Do any additional setup after loading the view.
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

- (IBAction)didCheckIn:(id)sender {
    NSLog(@"did checkin");
    
}

- (IBAction)didSelectSettings:(id)sender {
    NSLog(@"did select settings");
    [self performSegueWithIdentifier:@"UserShow" sender:self];
}


@end
