//
//  NotificationIndexViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "NotificationIndexViewController.h"
#import "NotificationCell.h"
#import "Notification.h"
#import "User+Rest.h"
#import "BaseView.h"
#import "Notification+Rest.h"
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
    
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, backButtonItem, nil ];
    
    self.title = NSLocalizedString(@"NOTIFICATIONS", @"Notifications title");
    [self setupFetchedResultsController];
    
    
    DLog(@"Ther are %d objects", [[self.fetchedResultsController fetchedObjects] count]);
    DLog(@"user has %d notifications", [self.currentUser.notifications count]);

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self markAsRead];
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
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"isRead" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO], nil];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.currentUser];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
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
    if ([notification.notificationType integerValue] == 1 ) {
        text = [NSString stringWithFormat:@"%@ %@ %@", notification.sender.normalFullName, NSLocalizedString(@"LEFT_A_COMMENT", @"Copy for commenting"), notification.placeTitle];
    } else if ([notification.type integerValue] == 2) {
        text = [NSString stringWithFormat:@"%@ %@.", notification.sender.normalFullName, NSLocalizedString(@"FOLLOWED_YOU", @"Copy for following")];
    }
    
    cell.notificationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    cell.notificationLabel.textColor = [UIColor blackColor];
    cell.notificationLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.notificationLabel.numberOfLines = 0;
    cell.notificationLabel.backgroundColor = [UIColor clearColor];
    [cell.profilePhotoView setProfileImageForUser:notification.sender];
    [cell.notificationLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldNameRange = [[mutableAttributedString string] rangeOfString:notification.sender.normalFullName options:NSCaseInsensitiveSearch];
        NSRange boldPlaceRange = [[mutableAttributedString string] rangeOfString:notification.placeTitle options:NSCaseInsensitiveSearch];
        
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldNameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldPlaceRange];
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    return cell;
}

- (void)markAsRead {
    [Notification markAllAsRead:^(bool status) {
        DLog(@"Marked as read");
    }
    onError:^(NSString *error) {
        DLog(@"failure marking as read");
    }
    forUser:self.currentUser
     inManagedObjectContext:self.managedObjectContext];
}


@end