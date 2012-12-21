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

#import "NotificationCell.h"
#import "Notification.h"
#import "User+Rest.h"
#import "Notification+Rest.h"
#import "RestNotification.h"
#import "ODRefreshControl.h"

#import "AppDelegate.h"
@interface NotificationIndexViewController ()

@end

@implementation NotificationIndexViewController

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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"SCREEN_NOTIFICATIONS"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //moving this will cause the table to reload on changes removing the pink "highlight" state 
    [self markAsRead];
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
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserShow"]) {
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
        cell.notificationLabel.backgroundColor = RGBCOLOR(245, 201, 216);
        cell.isNotRead = YES;
    } else {
        cell.backgroundView = nil;
        cell.notificationLabel.backgroundColor = [UIColor backgroundColor];
        cell.isNotRead = NO;
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
    notification.isRead = [NSNumber numberWithBool:YES];
    NSError *error;
    [self.managedObjectContext save:&error];
    [self.tableView reloadData];
    if ([notification.notificationType integerValue] == NotificationTypeNewComment) {
        [self performSegueWithIdentifier:@"CheckinShow" sender:notification];
    } else {
        [self performSegueWithIdentifier:@"UserShow" sender:notification.sender];
    }
    
}

#pragma mark - CoreData syncing
- (void)markAsRead {
    [self.managedObjectContext performBlock:^{
        [Notification markAllAsRead:^(bool status) {
            NSError *error;
            [self.managedObjectContext save:&error];
            AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [sharedAppDelegate.privateWriterContext performBlock:^{
                NSError *error;
                [sharedAppDelegate.privateWriterContext save:&error];
            }];

        } onError:^(NSError *error) {
            
        } forUser:self.currentUser inManagedObjectContext:self.managedObjectContext];
    }];
}

- (void)fetchResults:(id)refreshControl {
    [self.managedObjectContext performBlock:^{
        [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addNotificationsObject:notification];
                
            }
            NSError *error;
            [self.managedObjectContext save:&error];
            [refreshControl endRefreshing];
            [self.tableView reloadData];
            AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [sharedAppDelegate.privateWriterContext performBlock:^{
                NSError *error;
                [sharedAppDelegate.privateWriterContext save:&error];
            }];

        } onError:^(NSError *error) {
            DLog(@"Problem loading notifications %@", error);
            [refreshControl endRefreshing];
        }];

    }];
}
@end
