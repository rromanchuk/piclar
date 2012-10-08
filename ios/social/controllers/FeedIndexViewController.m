//
//  FeedIndexViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "FeedIndexViewController.h"

// Controllers
#import "PlaceShowViewController.h"
#import "PhotoNewViewController.h"
#import "CommentCreateViewController.h"
#import "UserShowViewController.h"
#import "NotificationIndexViewController.h"

// Views
#import "FeedCell.h"

// Models
#import "RestNotification.h"
#import "Notification+Rest.h"
#import "FeedItem+Rest.h"
#import "RestFeedItem.h"
#import "Place.h"
#import "Checkin.h"

@interface FeedIndexViewController () {
    BOOL isFullScreen;
    CGRect prevFrame;
    UIView *fullscreenBackground;
    PostCardImageView *fullscreenImage;
    BOOL noResultsModalShowing;
}

@end

@implementation FeedIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceShow"])
    {
        PlaceShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        vc.feedItem = feedItem;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.currentUser = self.currentUser;
        noResultsModalShowing = NO;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
    } else if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UserShowViewController *vc = (UserShowViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        User *user = (User *)sender;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.user = user;
    } else if ([[segue identifier] isEqualToString:@"Notifications"]) {
        NotificationIndexViewController *vc = (NotificationIndexViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    }
    
}

#pragma mark controller lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RestClient sharedClient].delegate = self;
    
    
    [self fetchResults];
    [self fetchNotifications];
    
    
    if (self.currentUser.numberOfUnreadNotifications > 0) {
        [self setupNotificationBarButton];
    } else {
        [self setupProfileBarButton];
    }
    
    [Flurry logEvent:@"SCREEN_FEED"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark CoreData syncing

- (void)fetchNotifications {
    [RestNotification load:^(NSSet *notificationItems) {
        for (RestNotification *restNotification in notificationItems) {
            DLog(@"notification %@", restNotification);
            Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
            DLog("notification feed item is %@", notification.feedItem);
            [self.currentUser addNotificationsObject:notification];
        }
        
        [self saveContext];
        if (self.currentUser.numberOfUnreadNotifications > 0) {
            [self setupNotificationBarButton];
        }
        DLog(@"user has %d total notfications", [self.currentUser.notifications count]);
        DLog(@"User has %d unread notifications", self.currentUser.numberOfUnreadNotifications);
    } onError:^(NSString *error) {
        DLog(@"Problem loading notifications %@", error);
    }];
}

- (void)fetchResults {
    if([[self.fetchedResultsController fetchedObjects] count] == 0)
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Show loading if no feed items are present yet")];
    
    
    [RestFeedItem loadFeed:^(NSArray *feedItems) {
        
        for (RestFeedItem *feedItem in feedItems) {
            [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:self.managedObjectContext];
        }
        [SVProgressHUD dismiss];
        [self saveContext];
        [self.tableView reloadData];
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            [self dismissNoResultsView];
        }
    } onError:^(NSString *error) {
        DLog(@"Problem loading feed %@", error);
        [SVProgressHUD showErrorWithStatus:error];
    }
                  withPage:1];
    
    
}


# pragma mark - UINavigationBarSetup
- (void)setupNotificationBarButton {
    UIImage *notificationsImage = [UIImage imageNamed:@"notifications.png"];
    UIBarButtonItem *notificationButton = [UIBarButtonItem barItemWithImage:notificationsImage target:self action:@selector(didSelectNotifications:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, notificationButton, nil];
}

- (void)setupProfileBarButton {
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];
}


# pragma mark - User events
- (IBAction)didSelectSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserShow" sender:self.currentUser];
}


- (IBAction)didCheckIn:(id)sender {
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (IBAction)didSelectNotifications:(id)sender {
    [self performSegueWithIdentifier:@"Notifications" sender:self];
}


- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"liking feedItem %@", feedItem.checkin.place.title);
    
    DLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    if ([feedItem.meLiked boolValue]) {
        //Update the UI now
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] - 1)];
        feedItem.meLiked = [NSNumber numberWithBool:NO];
        [self.tableView reloadData];
        [feedItem unlike:^(RestFeedItem *restFeedItem) {
            feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
            
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
        } onError:^(NSString *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            feedItem.meLiked = [NSNumber numberWithBool:YES];
            feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        //Update the UI so the responsiveness seems fast
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
        feedItem.meLiked = [NSNumber numberWithBool:YES];
        [self.tableView reloadData];
        [feedItem like:^(RestFeedItem *restFeedItem)
         {
             DLog(@"saving favorite counts with %d", restFeedItem.favorites);
             feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
             feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
         }
               onError:^(NSString *error)
         {
             // Request failed, we need to back out the temporary chagnes we made
             feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] - 1)];
             feedItem.meLiked = [NSNumber numberWithBool:NO];
             [SVProgressHUD showErrorWithStatus:error];
         }];
    }
    
    
}



#pragma mark CoreData methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (void)mergeChanges:(NSNotification*)notification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}



# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - NetworkReachabilityDelegate
- (void)networkReachabilityDidChange:(BOOL)connected {
    DLog(@"NETWORK AVAIL CHANGED");
    [self.tableView reloadData];
    [self fetchResults];
}



@end
