//
//  ApplicatonNavigationController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApplicatonNavigationController.h"
#import "UIBarButtonItem+Borderless.h"
#import "CheckinViewController.h"
#import "FeedItem+Rest.h"
@interface ApplicatonNavigationController ()

@end

@implementation ApplicatonNavigationController


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
    [NotificationHandler shared].delegate = self;
	// Do any additional setup after loading the view.
}


- (IBAction)back:(id)sender {
    [self popViewControllerAnimated:YES];
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

#pragma mark - NotificationDisplayModalDelegate methods
- (void)presentControllerModally:(NSDictionary *)customData {
    ALog(@"presenting controller modally");
    //[self.visibleViewController presentModalViewController:vc animated:YES];
    FeedItem *feedItem = [FeedItem feedItemWithExternalId:[[customData objectForKey:@"extra"] objectForKey:@"feed_item_id"] inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
    [self.visibleViewController performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
}


@end
