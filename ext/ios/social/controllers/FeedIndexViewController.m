//
//  FeedIndexViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "FeedIndexViewController.h"

// Controllers
#import "PhotoNewViewController.h"
#import "CommentCreateViewController.h"
#import "NotificationIndexViewController.h"
#import "UserViewController.h"
#import "CheckinViewController.h"
#import "ApplicatonNavigationController.h"
#import "PlaceShowViewController.h"

// Views
#import "FeedCell.h"
#import "WarningBannerView.h"
#import "UserProfileHeader.h"
#import "SmallProfilePhoto.h"

// Models
#import "RestNotification.h"
#import "Notification+Rest.h"
#import "FeedItem+Rest.h"
#import "RestFeedItem.h"
#import "Place.h"
#import "Photo+Rest.h"

// Other
#import "Utils.h"
#import "AppDelegate.h"

// Categories
#import "NSDate+Formatting.h"

@interface FeedTitleActionSheet : UIActionSheet
@end

@implementation FeedTitleActionSheet
@end



@interface FeedIndexViewController () {
    BOOL isFullScreen;
    CGRect prevFrame;
    UIView *fullscreenBackground;
    CheckinPhoto *fullscreenImage;
}

@end

@implementation FeedIndexViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
       self.noResultsFooterView = (FeedIndexNoResults *)[[[NSBundle mainBundle] loadNibNamed:@"FeedIndexNoResults" owner:self options:nil] objectAtIndex:0];
        self.noResultsFooterView.feedEmptyLabel.text = NSLocalizedString(@"FEED_IS_EMPTY", @"Empty feed");
        [self.noResultsFooterView.checkinButton addTarget:self action:@selector(didCheckIn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}


#pragma mark CoreData methods
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    
    NSFetchRequest *request = [[self.managedObjectContext.persistentStoreCoordinator.managedObjectModel fetchRequestTemplateForName:@"mainFeed"] copy]; 
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sharedAt" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharedAppDelegate writeToDisk];
}


#pragma mark Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([[segue identifier] isEqualToString:@"Checkin"]) {
        ApplicatonNavigationController *nc = (ApplicatonNavigationController *)[segue destinationViewController];
       nc.isChildNavigationalStack = YES;
       [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.currentUser = self.currentUser;
        [Location sharedLocation].delegate = vc;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
        vc.currentUser = self.currentUser;
    } else if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UserViewController *vc = (UserViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = (User *)sender;
        vc.currentUser = self.currentUser;
    }
    else if ([[segue identifier] isEqualToString:@"Notifications"]) {
        NotificationIndexViewController *vc = (NotificationIndexViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem*)sender;
        vc.currentUser = self.currentUser;
        vc.deletionDelegate = self;
    } else if ([segue.identifier isEqualToString:@"PlaceShow"]) {
        PlaceShowViewController *vc = (PlaceShowViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.place = (Place *)sender;
        vc.currentUser = self.currentUser;
    }
    
}

#pragma mark controller lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];

    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    
    self.footerView = [[LoadMoreFooter alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height - 60, self.tableView.frame.size.width, 60)];
    [ODRefreshControl setupRefreshForTableViewController:self withRefreshTarget:self action:@selector(fetchResults:)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    [RestClient sharedClient].delegate = self;
    [self setupFooter];
    
    // Updating the feed will automatically start on app launch, dont refetch every page load, let the user pull to refresh if needed.
    // TODO: maybe add add an age policy to force updates, push notifications should be able to trigger this ideally
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self fetchResults:self];
    }
    
    [self setupNavigationTitleWithNotifications];
    
    [Flurry logEvent:@"SCREEN_FEED"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharedAppDelegate writeToDisk];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Add gesture recognizer to visible cell on first load
    for (FeedCell *cell in [self.tableView visibleCells]) {
        if ([cell.checkinPhoto.gestureRecognizers count] == 0) {
            UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
            UILongPressGestureRecognizer *longPressPostCardPhoto = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTapPhoto:)];
            [cell.checkinPhoto addGestureRecognizer:tapPostCardPhoto];
            [cell.checkinPhoto addGestureRecognizer:longPressPostCardPhoto];
            cell.checkinPhoto.userInteractionEnabled = YES;
        }
        
    }
}

- (void)setupFooter {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        self.tableView.tableFooterView = self.noResultsFooterView;
        
    } else {
        //self.tableView.tableFooterView = self.footerView;
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - UITableViewDelegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ALog(@"number of liked %@", feedItem.numberOfLikes);
    
    static NSString *CellIdentifier = @"FeedCell";
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    cell.titleLabel.backgroundColor = [UIColor backgroundColor];
    cell.reviewLabel.backgroundColor = [UIColor backgroundColor];
    cell.dateLabel.backgroundColor = [UIColor backgroundColor];
    cell.commentButton.backgroundColor = [UIColor backgroundColor];
    cell.likeButton.backgroundColor = [UIColor backgroundColor];
    cell.star1.backgroundColor = cell.star2.backgroundColor = cell.star3.backgroundColor = cell.star4.backgroundColor = cell.star5.backgroundColor = [UIColor backgroundColor];
    cell.placeTypeImage.backgroundColor = [UIColor backgroundColor];
    
    if (cell == nil) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.titleLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        cell.reviewLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        cell.dateLabel.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
        
    } else {
        [cell.checkinPhoto.activityIndicator startAnimating];
    }
    
    if ([cell.profileImage.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressProfilePhoto:)];
        [cell.profileImage addGestureRecognizer:tapProfile];
    }
    
    if ([cell.titleLabel.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTitle:)];
        [cell.titleLabel addGestureRecognizer:tapTitle];
    }
    
    cell.profileImage.tag = indexPath.row;
    cell.titleLabel.tag = indexPath.row;
    cell.checkinPhoto.tag = indexPath.row;

    
    // Main image
    [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.photoUrl];
    //[cell.checkinPhoto setLargeCheckinImageForCheckin:[feedItem.checkin firstPhoto] withContext:self.managedObjectContext];
    
    
    // Profile image
    [cell.profileImage setProfileImageForUser:feedItem.user];
    // Set type category image
    cell.placeTypeImage.image = [Utils getPlaceTypeImageForFeedWithTypeId:[feedItem.place.typeId integerValue]];
    // Set timestamp
    cell.dateLabel.text = [feedItem.createdAt distanceOfTimeInWords];
    // Set stars
    [cell setStars:[feedItem.rating integerValue]];
    // Set review
    cell.reviewLabel.text = feedItem.review;
    // Set counters
    if ([feedItem.meLiked boolValue]) {
        cell.likeButton.selected = YES;
    } else {
        cell.likeButton.selected = NO;
    }
    
    [cell.likeButton setTitle:[feedItem.numberOfLikes stringValue] forState:UIControlStateNormal];
    [cell.likeButton setTitle:[feedItem.numberOfLikes stringValue] forState:UIControlStateSelected];
    [cell.likeButton setTitle:[feedItem.numberOfLikes stringValue] forState:UIControlStateHighlighted];
    
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateNormal];
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateHighlighted];
    [cell.commentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateSelected];
    
    // Set title attributed label
    NSString *text;
    text = [NSString stringWithFormat:@"%@ %@ %@", feedItem.user.fullName, NSLocalizedString(@"WAS_AT", nil), feedItem.place.title];
    cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];

    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.textColor = [UIColor defaultFontColor];
    if (feedItem.user.fullName && feedItem.place.title) {
        
        [cell.titleLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange boldNameRange = [[mutableAttributedString string] rangeOfString:feedItem.user.fullName options:NSCaseInsensitiveSearch];
            NSRange boldPlaceRange = [[mutableAttributedString string] rangeOfString:feedItem.place.title options:NSCaseInsensitiveSearch];
            
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
        UIView *view = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35) andMessage:NSLocalizedString(@"NO_CONNECTION_FOR_FEED", @"Unable to refresh content because no network")];
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

#pragma mark - CoreData syncing
- (void)fetchResults:(id)refreshControl {
    if([[self.fetchedResultsController fetchedObjects] count] == 0)
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Show loading if no feed items are present yet")];
    
    
    NSManagedObjectContext *loadFeedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    loadFeedContext.parentContext = self.managedObjectContext;
    
    [loadFeedContext performBlock:^{
        [RestFeedItem loadFeed:^(NSArray *feedItems) {
            for (RestFeedItem *feedItem in feedItems) {
                FeedItem *cdFeedItem = [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:loadFeedContext];
            }
            
            // push to parent
            NSError *error;
            [loadFeedContext save:&error];
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                [self.managedObjectContext save:&error];
                [SVProgressHUD dismiss];
                if ([refreshControl respondsToSelector:@selector(endRefreshing)])
                    [refreshControl endRefreshing];
                if ([feedItems count] > 0) {
                    [self.tableView reloadData];
                    [self setupFooter];
                }
                
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
                
        }];
       
        } onError:^(NSError *error) {
             ALog(@"Problem loading feed %@", error);
            if ([refreshControl respondsToSelector:@selector(endRefreshing)])
                [refreshControl endRefreshing];
        }];
    }];
    
    
    NSManagedObjectContext *notificationFeedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    notificationFeedContext.parentContext = self.managedObjectContext;
    User *user = [User userWithExternalId:self.currentUser.externalId inManagedObjectContext:notificationFeedContext];
    [notificationFeedContext performBlock:^{
        [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:notificationFeedContext];
                [user addNotificationsObject:notification];
            }
            
            // push to parent
            NSError *error;
            [notificationFeedContext save:&error];
                    
            // save parent to disk asynchronously
            [self.managedObjectContext performBlock:^{
                NSError *error;
                if (![self.managedObjectContext save:&error])
                {
                    // handle error
                    ALog(@"error %@", error);
                } else {
                  [self setupNavigationTitleWithNotifications];   
                }
            }];
            
        } onError:^(NSError *error) {
            ALog(@"Problem loading notifications %@", error);
        }];
    }];
    
}


# pragma mark - UINavigationBarSetup

- (void)setupNavigationTitleWithNotifications {
    //128x21
    UIImage *notificationsImage;
    if (self.currentUser.numberOfUnreadNotifications > 0) {
        notificationsImage = [UIImage imageNamed:@"ostronaut-logo-notifications.png"];
    } else {
        notificationsImage = [UIImage imageNamed:@"ostronaut-logo.png"];
    }
    
    UIButton *notificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [notificationButton addTarget:self action:@selector(didSelectNotifications:) forControlEvents:UIControlEventTouchUpInside];
    
    [notificationButton setBackgroundImage:notificationsImage forState:UIControlStateNormal];
    if (self.currentUser.numberOfUnreadNotifications > 0) {
        [notificationButton setFrame:CGRectMake(0, 0, 132, 25)];
        [notificationButton setTitle:[NSString stringWithFormat:@"%d", self.currentUser.numberOfUnreadNotifications] forState:UIControlStateNormal];
    } else {
        [notificationButton setFrame:CGRectMake(0, 0, 115, 18)];
    }
    [notificationButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [notificationButton.titleLabel setTextColor:[UIColor blackColor]];
    [notificationButton setTitleEdgeInsets:UIEdgeInsetsMake(-8, 118, 0, 0)];

    [self.navigationItem setTitleView:notificationButton];
}


# pragma mark - User events

- (IBAction)didTapTitle:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];

    
    FeedTitleActionSheet *as = [[FeedTitleActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:
                         feedItem.place.title, feedItem.user.fullName, nil];
    as.tag = row;
    [as showInView:[self.view window]];
    
}

- (void)userClickedCheckin {
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NO_LOCATION_SERVICES_ALERT", @"User needs to have location services turned for this to work")];
    } else {
        DLog(@"in delegate method of no results");
        [self.navigationController popViewControllerAnimated:NO];
        [self performSegueWithIdentifier:@"Checkin" sender:self];
    }
}

- (IBAction)didSelectSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserShow" sender:self.currentUser];
}

- (IBAction)didCheckIn:(id)sender {
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NO_LOCATION_SERVICES_ALERT", @"User needs to have location services turned for this to work")];
    } else {
        [self performSegueWithIdentifier:@"Checkin" sender:self];
    }
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
    DLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    [Flurry logEvent:@"LIKE_FROM_FEED"];
    if ([feedItem.meLiked boolValue]) {
        //Update the UI now
        feedItem.numberOfLikes = [NSNumber numberWithInteger:([feedItem.numberOfLikes integerValue] - 1)];
        feedItem.meLiked = [NSNumber numberWithBool:NO];
        //[self.tableView reloadData];
        [feedItem unlike:^(RestFeedItem *restFeedItem) {            
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            [feedItem updateFeedItemWithRestFeedItem:restFeedItem];
        } onError:^(NSError *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            feedItem.meLiked = [NSNumber numberWithBool:YES];
            feedItem.numberOfLikes = [NSNumber numberWithInteger:([feedItem.numberOfLikes integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    } else {
        //Update the UI so the responsiveness seems fast
        feedItem.numberOfLikes = [NSNumber numberWithInteger:([feedItem.numberOfLikes integerValue] + 1)];
        feedItem.meLiked = [NSNumber numberWithBool:YES];
        //[self.tableView reloadData];
        [feedItem like:^(RestFeedItem *restFeedItem)
         {
             [feedItem updateFeedItemWithRestFeedItem:restFeedItem];
         }
        onError:^(NSError *error)
         {
             // Request failed, we need to back out the temporary chagnes we made
             feedItem.numberOfLikes = [NSNumber numberWithInteger:([feedItem.numberOfLikes integerValue] - 1)];
             feedItem.meLiked = [NSNumber numberWithBool:NO];
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }];
    }
}

- (IBAction)didPressProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"feed item from didPress is %@", feedItem.user.fullName);
    
    [self performSegueWithIdentifier:@"UserShow" sender:feedItem.user];
}

- (IBAction)didLongTapPhoto:(UILongPressGestureRecognizer *)sender {
    ALog(@"in long tap");
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *as;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.view.tag inSection:0];
        FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *destructiveButtonTitle;
        if (self.currentUser == feedItem.user) {
            destructiveButtonTitle = NSLocalizedString(@"DELETE", @"Delete feed item button on long press of checkin photo");
        } else {
            destructiveButtonTitle = nil;
        }
        
        if ([UIActivityViewController class]) {
            
            as = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:NSLocalizedString(@"SHARE", nil), nil];
        } else if (destructiveButtonTitle) {
            as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
        } else {
            return;
        }
        as.tag = sender.view.tag;
        [as showInView:[self.view window]];
    }
}

#pragma mark - UIActionSheetDelegate methods
#warning this method sucks, clean it up
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:actionSheet.tag inSection:0];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ALog(@"buttonIndex is %d with %d buttons", buttonIndex, actionSheet.numberOfButtons);
    if ([actionSheet isKindOfClass:[FeedTitleActionSheet class]]) {
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"PlaceShow" sender:feedItem.place];
        } else if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"UserShow" sender:feedItem.user];
        }
    } else {
        if (actionSheet.numberOfButtons == 1) {
            
        } else {
            if (((self.currentUser != feedItem.user) && actionSheet.numberOfButtons == 2 && buttonIndex == 0) || (actionSheet.numberOfButtons == 3 && buttonIndex == 1)) {
                FeedCell *feedCell = (FeedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                NSArray *activityItems = @[feedCell.checkinPhoto.image];
                UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
                [self presentViewController:activityVC animated:TRUE completion:nil];
            } else if ((self.currentUser == feedItem.user) && buttonIndex == 0) {
                [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_FEED", @"Loading screen for deleting user's comment") maskType:SVProgressHUDMaskTypeGradient];
                [RestFeedItem deleteFeedItem:feedItem.externalId onLoad:^(RestFeedItem *restFeedItem) {
                    feedItem.isActive = [NSNumber numberWithBool:NO];
                    [feedItem deactivate];
                    [self saveContext];
                    [SVProgressHUD dismiss];
                    [self.tableView reloadData];
                } onError:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }];
            }
        }
    }
}


# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self.tableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
    [Location sharedLocation].delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
}

- (void)didCanceledCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
    [Location sharedLocation].delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
}

#pragma mark - NetworkReachabilityDelegate
- (void)networkReachabilityDidChange:(BOOL)connected {
    DLog(@"NETWORK AVAIL CHANGED");
    [self.tableView reloadData];
    [self fetchResults:nil];
}


#pragma mark - not used

- (IBAction)didTapPostCard:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
    
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
}


#pragma mark - UIScrollViewDelegate methods
-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.3];
    for (FeedCell *cell in [self.tableView visibleCells]) {
        if ([cell.checkinPhoto.gestureRecognizers count] > 0) {
            for (UIGestureRecognizer *rec in cell.checkinPhoto.gestureRecognizers) {
                [cell.checkinPhoto removeGestureRecognizer:rec];
                cell.checkinPhoto.userInteractionEnabled = NO;
            }
        }
        
    }
    
    CGPoint offset = self.tableView.contentOffset;
    CGRect bounds = self.tableView.bounds;
    CGSize size = self.tableView.contentSize;
    UIEdgeInsets inset = self.tableView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        // load more
    }

}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    for (FeedCell *cell in [self.tableView visibleCells]) {
        if ([cell.checkinPhoto.gestureRecognizers count] == 0) {
            UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
            UILongPressGestureRecognizer *longPressPostCardPhoto = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTapPhoto:)];
            [cell.checkinPhoto addGestureRecognizer:longPressPostCardPhoto];
            [cell.checkinPhoto addGestureRecognizer:tapPostCardPhoto];
            cell.checkinPhoto.userInteractionEnabled = YES;
        }
        
    }
}

#pragma mark - DeletionHandlerDelegate
- (void)deleteFeedItem: (FeedItem *)feedItem {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_FEED", @"Loading screen for deleting user's comment") maskType:SVProgressHUDMaskTypeGradient];
    [RestFeedItem deleteFeedItem:feedItem.externalId onLoad:^(RestFeedItem *restFeedItem) {
        [feedItem deactivate];
        [self saveContext];
        [SVProgressHUD dismiss];
        [((ApplicatonNavigationController *)self.navigationController) back:self];
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
    
}

@end
