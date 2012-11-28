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
    ALog(@"Reacting to notification received ");
    if ([[[customData objectForKey:@"extra"] objectForKey:@"type"] isEqualToString:@"notification_comment"]) {
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LOADING", nil)];
        [[NotificationHandler shared].managedObjectContext performBlock:^{
            ALog(@"fetching for item %@", [[customData objectForKey:@"extra"] objectForKey:@"feed_item_id"]);
            [RestFeedItem loadByIdentifier:[[customData objectForKey:@"extra"] objectForKey:@"feed_item_id"] onLoad:^(RestFeedItem *restFeedItem) {
                FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                // push to parent
                ALog(@"Refreshed feedItem %@", feedItem);
                NSError *error;
                if (![[NotificationHandler shared].managedObjectContext save:&error])
                {
                    ALog(@"Error saving temporary context %@", error);
                }
                [SVProgressHUD dismiss];
                [self.visibleViewController performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
            } onError:^(NSString *error) {
                ALog(@"Error updating feedItem %@", error);
                [SVProgressHUD dismiss];
            }];
        }];

    } else if ([[[customData objectForKey:@"extra"] objectForKey:@"type"] isEqualToString:@"notification_friend"]) {
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LOADING", nil)];
        [[NotificationHandler shared].managedObjectContext performBlock:^{
            [RestUser loadByIdentifier:[[customData objectForKey:@"extra"] objectForKey:@"friend_id"] onLoad:^(RestUser *restUser) {
                User *user = [User userWithRestUser:restUser inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                NSError *error;
                if (![[NotificationHandler shared].managedObjectContext save:&error])
                {
                    ALog(@"Error saving temporary context %@", error);
                }
                [SVProgressHUD dismiss];
                [self.visibleViewController performSegueWithIdentifier:@"UserShow" sender:user];
            } onError:^(NSString *error) {
                [SVProgressHUD dismiss];
            }];
        }];
    }
}


@end
