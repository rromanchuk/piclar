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
#import "WarningBannerView.h"

// Models
#import "RestNotification.h"
#import "Notification+Rest.h"
#import "FeedItem+Rest.h"
#import "RestFeedItem.h"
#import "Place.h"
#import "Checkin+Rest.h"
#import "Photo+Rest.h"

// Other
#import "Utils.h"

// Categories
#import "NSDate+Formatting.h"

@interface FeedIndexViewController () {
    BOOL isFullScreen;
    CGRect prevFrame;
    UIView *fullscreenBackground;
    PostCardImageView *fullscreenImage;
    BOOL noResultsModalShowing;
}

@end

@implementation FeedIndexViewController

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
    [self setupFetchedResultsController];
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];

    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation-logo.png"]]];
    
    // If native pull to refresh is available, use it. 
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(fetchResults)
                 forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RestClient sharedClient].delegate = self;
    
    
    [self fetchResults];
    [self fetchNotifications];
    
    
    //if (self.currentUser.numberOfUnreadNotifications > 0) {
    if (YES) {
        [self setupNavigationTitleWithNotifications];
    } else {
        [self setupNavigationTitle];
    }
    
    [Flurry logEvent:@"SCREEN_FEED"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self dismissNoResultsView];
    } else {
        [self dismissNoResultsView];
    }
}

#pragma mark TableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    } else {
        [cell.checkinPhoto.activityIndicator startAnimating];
    }
    
    // Gesture recognizers
    
    UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressProfilePhoto:)];
    [cell.profileImage addGestureRecognizer:tapProfile];
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Main image
    [cell.checkinPhoto setCheckinPhotoWithURL:[feedItem.checkin firstPhoto].url];
    // Profile image
    [cell.profileImage setProfileImageWithUrl:feedItem.user.remoteProfilePhotoUrl];
    // Set type category image
    cell.placeTypeImage.image = [Utils getPlaceTypeImageWithTypeId:[feedItem.checkin.place.typeId integerValue]];
    // Set timestamp
    cell.dateLabel.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    // Set stars
    [cell setStars:[feedItem.checkin.userRating integerValue]];
    // Set review
    cell.reviewLabel.text = feedItem.checkin.review;
    // Set counters
    [cell.likeButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.likeButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateSelected];
    [cell.likeButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateNormal];
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateHighlighted];
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateSelected];
    
    // Set title attributed label
    NSString *text;
    text = [NSString stringWithFormat:@"%@ %@ %@", feedItem.user.normalFullName, NSLocalizedString(@"WAS_AT", nil), feedItem.checkin.place.title];
    cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.titleLabel.numberOfLines = 2;
    if (feedItem.user.fullName && feedItem.checkin.place.title) {
        
        [cell.titleLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange boldNameRange = [[mutableAttributedString string] rangeOfString:feedItem.user.normalFullName options:NSCaseInsensitiveSearch];
            NSRange boldPlaceRange = [[mutableAttributedString string] rangeOfString:feedItem.checkin.place.title options:NSCaseInsensitiveSearch];
            
            UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldNameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldPlaceRange];
            CFRelease(font);
            
            return mutableAttributedString;
        }];

    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 425;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((section == 0) && ([RestClient sharedClient].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)) {
        UIView *view = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_CONNECTION_FOR_FEED", @"Unable to refresh content because no network")];
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == 0) && ([RestClient sharedClient].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) ) {
        return 30;
    }
    return 0;
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
        [self endPullToRefresh];
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            [self dismissNoResultsView];
        }
    } onError:^(NSString *error) {
        DLog(@"Problem loading feed %@", error);
        [self endPullToRefresh];
        [SVProgressHUD showErrorWithStatus:error];
    }
                  withPage:1];
    
    
}

- (void)endPullToRefresh {
    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
    }
}


# pragma mark - UINavigationBarSetup
- (void)setupNotificationBarButton {
    UIImage *notificationsImage = [UIImage imageNamed:@"notifications.png"];
    UIBarButtonItem *notificationButton = [UIBarButtonItem barItemWithImage:notificationsImage target:self action:@selector(didSelectNotifications:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, notificationButton, nil];
}

- (void)setupNavigationTitle {
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation-logo.png"]]];
}

- (void)setupNavigationTitleWithNotifications {
    //128x21
    UIImage *notificationsImage = [UIImage imageNamed:@"ostronaut-logo-notifications.png"];
    UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [notificationButton addTarget:self action:@selector(didSelectNotifications:) forControlEvents:UIControlEventTouchUpInside];
    [notificationButton setFrame:CGRectMake(0, 0, 128, 21)];
    [notificationButton setImage:notificationsImage forState:UIControlStateNormal];
    [self.navigationItem setTitleView:notificationButton];
}


# pragma mark - User events

- (void)userClickedCheckin {
    DLog(@"in delegate method of no results");
    [self.navigationController popViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}


- (IBAction)didSelectSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserShow" sender:self.currentUser];
}


- (IBAction)didCheckIn:(id)sender {
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (IBAction)didSelectNotifications:(id)sender {
    [self performSegueWithIdentifier:@"Notifications" sender:self];
}

- (IBAction)didPressComment:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Comment" sender:feedItem];
    
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


- (IBAction)didPressProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"feed item from didPress is %@", feedItem.checkin.user.normalFullName);
    [self performSegueWithIdentifier:@"UserShow" sender:feedItem.checkin.user];
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

- (void)didCanceledCheckingIn {
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

#pragma mark - No Results

- (void)dismissNoResultsView {
    if (noResultsModalShowing) {
        noResultsModalShowing = NO;
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)displayNoResultsView {
    if (!noResultsModalShowing) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        NoResultscontrollerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NoResultsController"];
        vc.delegate = self;
        noResultsModalShowing = YES;
        [vc.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation-logo.png"]]];
        
        UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
        UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
        UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixed.width = 5;
        vc.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];
        
        
        UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
        UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
        vc.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
        
        [self.navigationController pushViewController:vc animated:NO];
    }
}


#pragma mark - not used

//- (IBAction)didTapPostCard:(id)sender {
//    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
//    //PostCardImageView *original = (PostCardImageView *)tap.view;
//    PostCardImageView *image = (PostCardImageView *)tap.view;
//    
//    //[image setOrigin:CGPointMake(original.frame.origin.x, original.frame.origin.y+90)];
//    //window size is bigger, so to set an image frame visionary at same place, you need to set origin point lower
//    
//    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    
//    
//    
//    if (!isFullScreen) {
//        
//        DLog(@"x:%f y:%f", image.frame.origin.x, image.frame.origin.y);
//        
//        CGRect frame = [image.superview convertRect:image.frame toView:sharedAppDelegate.window];
//        fullscreenImage = [[PostCardImageView alloc] initWithFrame:frame];
//        DLog(@"x:%f y:%f", fullscreenImage.frame.origin.x, fullscreenImage.frame.origin.y);
//        prevFrame = fullscreenImage.frame;
//        fullscreenImage.image = [image.image copy];
//        [fullscreenImage.activityIndicator stopAnimating];
//        
//        fullscreenBackground = [[UIView alloc] initWithFrame:sharedAppDelegate.window.frame];
//        UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
//        [fullscreenBackground addGestureRecognizer:tapPostCardPhoto];
//        fullscreenBackground.backgroundColor = [UIColor clearColor];
//        [fullscreenBackground addSubview:fullscreenImage];
//        [sharedAppDelegate.window addSubview:fullscreenBackground];
//        [UIView animateWithDuration:0.5
//                         animations:^{
//                             [fullscreenImage setFrame:CGRectMake(0,
//                                                                  100,
//                                                                  320,
//                                                                  320)];
//                             fullscreenBackground.backgroundColor = [UIColor blackColor];
//                         }completion:^(BOOL finished){
//                             isFullScreen = YES;
//                         }];
//        return;
//    } else {
//        //        [image removeFromSuperview];
//        //        [self.view addSubview:image];
//        [UIView animateWithDuration:0.5
//                         animations:^{
//                             [fullscreenImage setFrame:prevFrame];
//                             fullscreenBackground.backgroundColor = [UIColor clearColor];
//                         }completion:^(BOOL finished){
//                             [fullscreenBackground removeFromSuperview];
//                             isFullScreen = NO;
//                         }];
//        return;
//    }
//    
//    
//    
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    DLog(@"did finish decelerating");
//    NSArray *visibleCells = self.tableView.visibleCells;
//    for (PostCardCell *cell in visibleCells) {
//        cell.postcardPhoto.userInteractionEnabled = YES;
//    }
//}
//

@end