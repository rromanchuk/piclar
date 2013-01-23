//
//  BaseViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (needsBackButton) {
        UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
        UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: backButtonItem, nil ];
    } else if (needsDismissButton) {
        UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
        UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];        
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: dismissButtonItem, nil]];
    }else {
        CALayer *layer = self.view.layer;
        //layer.frame = self.view.frame;
        layer.cornerRadius = 10.0;
        layer.masksToBounds = YES;
    }
    
    // Do any additional setup after loading the view.
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
