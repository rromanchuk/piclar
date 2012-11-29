//
//  NotificationIndexViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

// Controllers
#import "NotificationIndexViewController.h"
#import "CheckinViewController.h"
#import "CommentCreateViewController.h"

#import "NotificationCell.h"
#import "Notification.h"
#import "User+Rest.h"
#import "Notification+Rest.h"
#import "RestNotification.h"
#import "ODRefreshControl.h"
@interface NotificationIndexViewController ()

@end

@implementation NotificationIndexViewController

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
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil ];
    
    self.title = NSLocalizedString(@"NOTIFICATIONS", @"Notifications title");
    [self setupFetchedResultsController];
    
    
    DLog(@"Ther are %d objects", [[self.fetchedResultsController fetchedObjects] count]);
    DLog(@"user has %d notifications", [self.currentUser.notifications count]);

	// If native pull to refresh is available, use it.
    [ODRefreshControl setupRefreshForTableViewController:self withRefreshTarget:self action:@selector(fetchResults:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"SCREEN_NOTIFICATION_INDEX"];
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    [self markAsRead];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"SCREEN_NOTIFICATIONS"];
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


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"isRead" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.currentUser];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Comment"]) {
        CommentCreateViewController *vc = (CommentCreateViewController *) segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.notification = (Notification *)sender;
        vc.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"UserShow"]) {
        NewUserViewController *vc = (NewUserViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = (User *)sender;
        vc.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItemId = ((Notification *)sender).feedItemId;
        vc.currentUser = self.currentUser;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationCell";
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    Notification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (![notification.isRead boolValue]) {
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = RGBCOLOR(245, 201, 216);
        cell.backgroundView = bgColorView;
    } else {
        cell.backgroundView = nil;
    }
    
    DLog(@"users name is %@", notification.sender.normalFullName);
    NSString *text;
    if ([notification.notificationType integerValue] == NotificationTypeNewComment ) {
        text = [NSString stringWithFormat:@"%@ %@ %@.", notification.sender.normalFullName, NSLocalizedString(@"LEFT_A_COMMENT", @"Copy for commenting"), notification.placeTitle];
    } else if ([notification.notificationType integerValue] == NotificationTypeNewFriend) {
        text = [NSString stringWithFormat:@"%@ %@.", notification.sender.normalFullName, NSLocalizedString(@"FOLLOWED_YOU", @"Copy for following")];
    }
    
    cell.notificationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    cell.notificationLabel.textColor = [UIColor defaultFontColor];
    cell.notificationLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.notificationLabel.numberOfLines = 0;
    cell.notificationLabel.backgroundColor = [UIColor clearColor];
    [cell.profilePhotoView setProfileImageForUser:notification.sender];
    [cell.notificationLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange boldNameRange;
        NSRange boldPlaceRange;
        if (notification.sender.normalFullName.length > 0) {
            boldNameRange = [[mutableAttributedString string] rangeOfString:notification.sender.normalFullName options:NSCaseInsensitiveSearch];
        }
        if (notification.placeTitle.length > 0) {
            boldPlaceRange = [[mutableAttributedString string] rangeOfString:notification.placeTitle options:NSCaseInsensitiveSearch];
        }
        
        
        
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            if (notification.sender.normalFullName.length > 0)
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldNameRange];
            if (notification.placeTitle.length > 0)
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldPlaceRange];
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Notification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([notification.notificationType integerValue] == NotificationTypeNewComment) {
        [self performSegueWithIdentifier:@"CheckinShow" sender:notification];
    } else {
        [self performSegueWithIdentifier:@"UserShow" sender:notification.sender];
    }
    
}

- (void)markAsRead {
    [Notification markAllAsRead:^(bool status) {
        DLog(@"Marked as read");
    }
    onError:^(NSError *error) {
        DLog(@"failure marking as read");
    }
    forUser:self.currentUser
     inManagedObjectContext:self.managedObjectContext];
}



- (void)fetchResults:(id)refreshControl {
    [RestNotification load:^(NSSet *notificationItems) {
        for (RestNotification *restNotification in notificationItems) {
            Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
            [self.currentUser addNotificationsObject:notification];

        }
        [self saveContext];
        [refreshControl endRefreshing];
        [self.tableView reloadData];
    } onError:^(NSError *error) {
        DLog(@"Problem loading notifications %@", error);
        [refreshControl endRefreshing];
    }];
}


#pragma mark CoreData methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *__managedObjectContext = self.managedObjectContext;
    if (__managedObjectContext != nil) {
        if ([__managedObjectContext hasChanges] && ![__managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}



@end
