
#import "CheckinsIndexViewController.h"
#import "PostCardCell.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceShowViewController.h"
#import "CommentNewViewController.h"
#import "RestCheckin.h"
#import "RestPlace.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
#define USER_COMMENT 251.0f
#define OTHER_COMMENTS 211.0f
@interface CheckinsIndexViewController ()

@end

@implementation CheckinsIndexViewController
@synthesize sampleUserCommentLabel;
@synthesize sampleCommentsLabel;
@synthesize managedObjectContext;

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
    //[self setupFetchedResultsController];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    [self fetchResults];
      	// Do any additional setup after loading the view.
    [RestCheckin createCheckinWithPlace:[NSNumber numberWithInt:1786] 
                               andPhoto:[UIImage imageNamed:@"sample-photo1-show"]
                             andComment:@"This is a test comment"
                              andRating:4
                                 onLoad:^(RestCheckin *checkin) {
                                     NSLog(@"");
                                 } 
                                onError:^(NSString *error) {
                                    NSLog(@"");
                                }];

}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}

- (void)viewDidUnload
{
    [self setSampleUserCommentLabel:nil];
    [self setSampleCommentsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceShow"])
    {
        PlaceShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
        //vc.place = place;
        
        [RestPlace loadByIdentifier:1708 
                             onLoad:^(RestPlace *place) {
                                 NSLog(@"%@", place);
                                 [vc.tableView reloadData];
                             } onError:^(NSString *error) {
                                 NSLog(error);
                             }];
        
        
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinCell";
    PostCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PostCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"GOT FeedItem FROM FETCHED RESULTS %@", feedItem);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:feedItem.checkin.createdAt];    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [NSLocale currentLocale];
    NSString *monthName = [[df monthSymbols] objectAtIndex:([components month]-1)];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%d", [components day]];
    cell.monthLabel.text = monthName;
    
    // Resize comment label
    cell.commentLabel.text = feedItem.checkin.comment;
    CGSize expectedLabelSize = [feedItem.checkin.comment sizeWithFont:cell.commentLabel.font 
                                constrainedToSize:cell.commentLabel.frame.size
                                    lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect newFrame = cell.commentLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    cell.commentLabel.frame = newFrame;
    cell.commentLabel.numberOfLines = 0;
    [cell.commentLabel sizeToFit];
    
    
    
    cell.postCheckedInAtText.text = NSLocalizedString(@"CHECKED_IN_AT", @"Copy for User x 'checked in at..' ");
    cell.postCardUserName.text = [feedItem.user.firstname stringByAppendingFormat:@" %@", feedItem.user.lastname];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.postcardPhoto setImageWithURL:[NSURL URLWithString:checkin.firstPhoto.url]];
    UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    //cell.profilePhoto.image = [newImage thumbnailImage:[Utils sizeForDevice:33.0] transparentBorder:2 cornerRadius:30 interpolationQuality:kCGInterpolationHigh];
    cell.profilePhoto.image = newImage;

    
    //    CALayer *layer = cell.profilePhoto.layer;
//    [layer setCornerRadius:16];
//    [layer setBorderWidth:1];
//    [layer setMasksToBounds:YES];
//    layer.borderColor = [[UIColor grayColor] CGColor];
    //[layer setShadowColor:[UIColor blackColor].CGColor];
    //[layer setShadowOpacity:0.8];
    //[layer setShadowRadius:3.0];
    //[layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //cell.profilePhoto.image = profilePhoto;
    //UIImage *newImage = [UIImage imageNamed:@"profile-demo.png"];
    //cell.profilePhoto.image = [newImage thumbnailImage:33 transparentBorder:1 cornerRadius:1 interpolationQuality:1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    self.sampleUserCommentLabel.text = checkin.comment;
    CGSize expectedUserCommentLabelSize = [checkin.comment sizeWithFont:self.sampleUserCommentLabel.font 
                                           constrainedToSize:self.sampleUserCommentLabel.frame.size
                                               lineBreakMode:UILineBreakModeWordWrap];
    
    //int size = 282 + expectedUserCommentLabelSize.height;
    
    return 282;
}


- (void)fetchResults {
    [RestFeedItem loadFeed:^(NSArray *feedItems) 
                {
                    for (RestFeedItem *feedItem in feedItems) {
                        NSLog(@"FindOrCreate FeedItem with RestFeedItem: %@", feedItem);
                        [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:self.managedObjectContext];
                    }
                }
                onError:^(NSString *error) {
                    [SVProgressHUD showErrorWithStatus:error duration:1.0];
                }
                withPage:1];

}

     
- (IBAction)didSelectSettings:(id)sender {
    NSLog(@"did select settings");
    [self performSegueWithIdentifier:@"UserShow" sender:self];
}

- (IBAction)didCheckIn:(id)sender {
    NSLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    [checkin like:^(RestCheckin *restCheckin) 
//            {
//                NSLog(@"saving favorite counts with @%", restCheckin.favorites);
//                checkin.favorites = [NSNumber numberWithInt:restCheckin.favorites];
//                [self saveContext];
//                [self.tableView reloadData];
//        
//            }
//            onError:^(NSString *error) 
//            {
// 
//            }];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
@end
