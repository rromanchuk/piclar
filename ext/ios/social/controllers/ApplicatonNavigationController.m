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


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        self.notificationBanner = (NotificationBanner *)[[[NSBundle mainBundle] loadNibNamed:@"NotificationBanner" owner:self options:nil] objectAtIndex:0];
        [self.notificationBanner.dismissButton addTarget:self action:@selector(didDismissNotificationBanner:) forControlEvents:UIControlEventTouchUpInside];
        [self.notificationBanner.notificationTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapNotificationBanner:)]];
        self.isChildNavigationalStack = NO;
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
- (void)presentNotificationApplicationLaunch:(NSDictionary *)customData {
    ALog(@"Reacting to notification received ");
    NSString *type = [[customData objectForKey:@"extra"] objectForKey:@"type"];

    if ([type isEqualToString:@"notification_comment"]) {
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil)];
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
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
                [SVProgressHUD dismiss];
            }];
        }];

    } else if ([type isEqualToString:@"notification_friend"]) {
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil)];
        [[NotificationHandler shared].managedObjectContext performBlock:^{
            [RestUser loadByIdentifier:[[customData objectForKey:@"extra"] objectForKey:@"friend_id"] onLoad:^(RestUser *restUser) {
                User *user = [User findOrCreateUserWithRestUser:restUser inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                [SVProgressHUD dismiss];
                [self.visibleViewController performSegueWithIdentifier:@"UserShow" sender:user];
            } onError:^(NSError *error) {
                [SVProgressHUD dismiss];
            }];
        }];
    } else if ([type isEqualToString:@"notification_checkin"]) {
        [Flurry logEvent:@"ENTER_FROM_CHECKIN_NOTIFICATION"];
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil)];
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
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
                [SVProgressHUD dismiss];
            }];
        }];

    } else if ([type isEqualToString:@"notification_like"]) {
        [Flurry logEvent:@"ENTER_FROM_LIKE_NOTIFICATION"];
        [self popToRootViewControllerAnimated:NO];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil)];
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
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
                [SVProgressHUD dismiss];
            }];
        }];
    }
    
}

- (void)presentIncomingNotification:(NSDictionary *)customData notification:(NSDictionary *)notification {
    NSString *type = [[customData objectForKey:@"extra"] objectForKey:@"type"];
    NSString *alert = [[notification objectForKey:@"aps"] objectForKey:@"alert"];
    
#warning don't ask me why, but if this is not reinstantiated it gets very screwed up when it's reused
    self.notificationBanner = (NotificationBanner *)[[[NSBundle mainBundle] loadNibNamed:@"NotificationBanner" owner:self options:nil] objectAtIndex:0];
    [self.notificationBanner.dismissButton addTarget:self action:@selector(didDismissNotificationBanner:) forControlEvents:UIControlEventTouchUpInside];
    [self.notificationBanner.notificationTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapNotificationBanner:)]];

    ALog(@"got alert %@", alert);
    ALog(@"got notification %@ and customData %@", customData, notification);
    if([type isEqualToString:@"notification_comment"]) {
        [Flurry logEvent:@"COMMENT_NOTIFICATION_DURING_SESSION"];
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
                self.notificationBanner.sender = feedItem;
                self.notificationBanner.notificationTextLabel.text = alert;
                self.notificationBanner.segueTo = @"CheckinShow";
                User *user = [User userWithExternalId:[[customData objectForKey:@"extra"] objectForKey:@"user_id"] inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                if (user) {
                    self.notificationBanner.user = user;
                } else {
                    
                }
                [self showNotificationBanner];
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
            }];
        }];

    } else if ([type isEqualToString:@"notification_like"]) {
        [Flurry logEvent:@"LIKE_NOTIFICATION_DURING_SESSION"];
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
                self.notificationBanner.sender = feedItem;
                self.notificationBanner.notificationTextLabel.text = alert;
                self.notificationBanner.segueTo = @"CheckinShow";
                User *user = [User userWithExternalId:[[customData objectForKey:@"extra"] objectForKey:@"user_id"] inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                if (user) {
                    self.notificationBanner.user = user;
                } else {
                    
                }
                [self showNotificationBanner];
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
            }];
        }];

    } else if ([type isEqualToString:@"notification_friend"]) {
        [Flurry logEvent:@"FOLLOW_NOTIFICATION_DURING_SESSION"];
        [[NotificationHandler shared].managedObjectContext performBlock:^{
            ALog(@"fetching for item %@", [[customData objectForKey:@"extra"] objectForKey:@"feed_item_id"]);
            [RestUser loadByIdentifier:[[customData objectForKey:@"extra"] objectForKey:@"user_id"] onLoad:^(RestUser *restUser) {
                User *user = [User findOrCreateUserWithRestUser:restUser inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                
                self.notificationBanner.segueTo = @"UserShow";
                self.notificationBanner.notificationTextLabel.text = alert;
                self.notificationBanner.user = user;
                self.notificationBanner.sender = user;
                [self showNotificationBanner];
            } onError:^(NSError *error) {
                
            }];
        }];
        
    } else if ([type isEqualToString:@"notification_checkin"]) {
        [Flurry logEvent:@"CHECKIN_NOTIFICATION_DURING_SESSION"];
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
                self.notificationBanner.sender = feedItem;
                self.notificationBanner.notificationTextLabel.text = alert;
                self.notificationBanner.segueTo = @"CheckinShow";
                User *user = [User userWithExternalId:[[customData objectForKey:@"extra"] objectForKey:@"user_id"] inManagedObjectContext:[NotificationHandler shared].managedObjectContext];
                if (user) {
                    self.notificationBanner.user = user;
                } else {
                    
                }
                [self showNotificationBanner];
            } onError:^(NSError *error) {
                ALog(@"Error updating feedItem %@", error);
            }];
        }];

    }
    [self reloadFeedIfNeeded];
}

- (void)reloadFeedIfNeeded {
    if ([self.visibleViewController respondsToSelector:@selector(setupNavigationTitleWithNotifications)]) {
        [self.visibleViewController performSelector:@selector(setupNavigationTitleWithNotifications)];
    }
}


#pragma mark - Notification banner methods

- (void)showNotificationBanner {
    [self.notificationBanner setupView];
    
    
    self.notificationBanner.alpha = 0.0;
    if ([self.visibleViewController respondsToSelector:@selector(tableView)] || [self.visibleViewController respondsToSelector:@selector(collectionView)]) {
        ALog(@"has table view!!!!");
        //[self.visibleViewController.view.superview addSubview:self.notificationBanner];
        [self.visibleViewController.view.superview insertSubview:self.notificationBanner aboveSubview:self.visibleViewController.view.superview];
    } else {
        ALog(@"has no table view!!!");
        [self.visibleViewController.view insertSubview:self.notificationBanner aboveSubview:self.visibleViewController.view];
    }
    
    
    [NotificationBanner animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.notificationBanner.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(hideNotificationBanner) withObject:nil afterDelay:5.0];
                     }
     ];
}

- (void)hideNotificationBanner {
    
    [NotificationBanner animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.notificationBanner.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.notificationBanner removeFromSuperview];
                     }
     ];

}

- (IBAction)didDismissNotificationBanner:(id)sender {
    [self hideNotificationBanner];
}

- (IBAction)didTapNotificationBanner:(id)sender {
    // Don't allow the user to interupt his checkin flow. maybe change this when we know how to handle this better
    if (!self.isChildNavigationalStack) {
        [self popToRootViewControllerAnimated:NO];
        [self.visibleViewController performSegueWithIdentifier:self.notificationBanner.segueTo sender:self.notificationBanner.sender];
    }
}
@end