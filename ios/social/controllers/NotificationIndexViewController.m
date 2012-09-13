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
    self.title = NSLocalizedString(@"NOTIFICATIONS", @"Notifications title");
    [self setupFetchedResultsController];
    DLog(@"Ther are %d objects", [[self.fetchedResultsController fetchedObjects] count]);
    DLog(@"user has %d notifications", [self.currentUser.notifications count]);

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    DLog(@"users name is %@", notification.sender.normalFullName);
    NSString *text;
    if (notification.type == @"new_comment") {
        text = [NSString stringWithFormat:@"%@ %@ %@", notification.sender.normalFullName, NSLocalizedString(@"LEFT_A_COMMENT", @"Copy for commenting"), notfi];
    } else if (notification.type == @"new_friend") {
        text = [NSString stringWithFormat:@"%@ %@ %@", notification.sender.normalFullName, NSLocalizedString(@"FOLLOWED_YOU", @"Copy for following"), @"Test place"];
    }
    text = [NSString stringWithFormat:@"%@ %@ %@", notification.sender.normalFullName, NSLocalizedString(@"LEFT_A_COMMENT", @"Copy for commenting"), @"Test place"];
    
    cell.notificationLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    cell.notificationLabel.textColor = [UIColor blackColor];
    cell.notificationLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.notificationLabel.numberOfLines = 0;
    
    [cell.notificationLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"LEFT_A_COMMENT", @"Copy for commenting") options:NSCaseInsensitiveSearch];
        
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    return cell;
}



@end
