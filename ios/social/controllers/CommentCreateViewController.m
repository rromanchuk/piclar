//
//  CommentCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//

#import "AppDelegate.h"

// Controllers
#import "BaseNavigationViewController.h"
#import "CommentCreateViewController.h"
#import "UsersListViewController.h"
#import "ApplicatonNavigationController.h"

//CoreData
#import "User+Rest.h"
#import "Place.h"
#import "Checkin.h"
#import "Comment+Rest.h"
#import "FeedItem+Rest.h"
#import "Notification+Rest.h"


// Rest
#import "NSDate+Formatting.h"
#import "RestFeedItem.h"
#import "RestNotification.h"

//Categories
#import "UIImageView+AFNetworking.h"
#import "UIBarButtonItem+Borderless.h"
#import "NSString+Formatting.h"

// Views
#import "BaseView.h"
#import "NewCommentCell.h"
#import "NoCommentsFooter.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "ThreadedUpdates.h"
#define COMMENT_LABEL_WIDTH 253.0f
#define REVIEW_COMMENT_LABEL_WIDTH 253.0f
#define HEADER_HEIGHT 74.0f

@interface CommentCreateViewController ()

@property (nonatomic) BOOL beganUpdates;

@end

@implementation CommentCreateViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"LEAVE_A_COMMENT", @"Title for leaving a comment");
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [self setupFooterView];
    
    ALog(@"header height is %f", self.headerView.frame.size.height);
}

- (NSString *)buildCommentersString {
    NSMutableArray *likers = [[NSMutableArray alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    if ([self.feedItem.liked count] > 0) {
        for (User *user in self.feedItem.liked) {
            DLog(@"found commment %@", user.fullName);
            [likers addObject:user.fullName];
        }
        DLog(@"commentors %@", likers);
        int i;
        for (i=0; i < 4 && i < [likers count]; i++) {
            NSString *name = [likers objectAtIndex:i];
            DLog(@"adding %@", name);
            [names addObject:name];
        }
    }
    
    NSString *copy;
    int totalLikers = [likers count];
    if (totalLikers == 1) {
        // <name> likes this
        copy = [NSString stringWithFormat:@"%@ %@.", [names objectAtIndex:0], NSLocalizedString(@"SINGULAR_LIKES_THIS", nil)];
    } else if (totalLikers == 2) {
        // <name1> and <name2> like this.
        copy = [NSString stringWithFormat:@"%@ %@ %@ %@.", [names objectAtIndex:0], NSLocalizedString(@"AND", nil), [names objectAtIndex:1], NSLocalizedString(@"PLURAL_LIKE_THIS", nil)];
    } else if (totalLikers == 3) {
        //<name1>, <name2> and <name3> like this.
        copy = [NSString stringWithFormat:@"%@, %@, %@ %@ %@.", [names objectAtIndex:0], [names objectAtIndex:1], NSLocalizedString(@"AND", nil), [names objectAtIndex:2], NSLocalizedString(@"PLURAL_LIKE_THIS", nil)];
    } else if (totalLikers == 4) {
       //<name1>, <name2>, <name3> and 1 other like this.
        copy = [NSString stringWithFormat:@"%@, %@, %@ %@ 1 %@ %@.", [names objectAtIndex:0], [names objectAtIndex:1], [names objectAtIndex:2], NSLocalizedString(@"AND", nil),  NSLocalizedString(@"OTHER", nil), NSLocalizedString(@"SINGULAR_LIKES_THIS", nil)];
    } else if (totalLikers > 4) {
        //<name1>, <name2>, <name3> and 2 others like this
        int remainingLikers = totalLikers - 3;
        copy = [NSString stringWithFormat:@"%@, %@, %@ %@ %d %@ %@.", [names objectAtIndex:0], [names objectAtIndex:1], [names objectAtIndex:2], NSLocalizedString(@"AND", nil), remainingLikers, NSLocalizedString(@"OTHERS", nil), NSLocalizedString(@"PLURAL_LIKE_THIS", nil)];

    }

    return copy;
}

- (void)setupView {
      
    if ([self.feedItem.meLiked boolValue]) {
        self.likeButton.selected = YES;
    } else {
        self.likeButton.selected = NO;
    }
    
    [self.likeButton setTitle:[self.feedItem.numberOfLikes stringValue] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self.feedItem.numberOfLikes stringValue] forState:UIControlStateSelected];
    [self.likeButton setTitle:[self.feedItem.numberOfLikes stringValue] forState:UIControlStateHighlighted];
    [self.likersBanner layoutViewForLikers:self.feedItem.liked];
    
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        self.tableView.tableFooterView = [[NoCommentsFooter alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 200)];;
    } else {
        self.tableView.tableFooterView = nil;
    }

    //[self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setFooterView:nil];
    [self setHeaderView:nil];
    [self setTableView:nil];
    [self setLikeLabel:nil];
    [self setDisclosureIndicator:nil];
    [self setLikersBanner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.view.layer setCornerRadius:0.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
//    if(self.notification) { // Check if we are coming from notifications 
//        FeedItem *feedItem = [FeedItem feedItemWithExternalId:self.notification.feedItemId inManagedObjectContext:self.managedObjectContext];
//        if(feedItem) { // make sure this notification knows about its associated feed tiem
//            self.feedItem = feedItem;
//        } else {
//            // For whatever reason CoreData doesn't know about this feedItem, we need to pull it form the server and build it
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
//            [RestFeedItem loadByIdentifier:self.notification.feedItemId onLoad:^(RestFeedItem *restFeedItem) {
//                FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
//                self.feedItem = feedItem;
//                // we just replaced self.feedItem, we need to reinstantiate the fetched results controller since it is now most likely invalid
//                [self setupFetchedResultsController];
//                [self saveContext];
//                [SVProgressHUD dismiss];
//            } onError:^(NSError *error) {
//#warning crap, we couldn't load the feed item, we should show the error "try again" screen here...since this experience will be broken 
//                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//            }];
//            
//        }
//    } else {
//        // This is a normal segue from the feed, we don't have to do anything special here
//    }
    
    // Let's make sure comments are current and ask the server (this will automatically update the feed as well)
    [self setupFetchedResultsController];
    [self updateFeedItem];
    [self setupView];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Automatically show the keyboard if there are no coments
    if ([self.feedItem.comments count] == 0)
        [self.commentView becomeFirstResponder];
    
    [self setupView];
    [Flurry logEvent:@"SCREEN_COMMENT_CREATE"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.commentView resignFirstResponder];
    [self.navigationController.view.layer setCornerRadius:10.0];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharedAppDelegate writeToDisk];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.likeLabel.text = @"";
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
#warning unfortunately, feedItems can be orphaned coming from the notifications profile because notifications don't contain feed item structure, so we are hoping that the feedItem already exists in CoreData. We can't do this processing on the previous controller becuase it would delay the tap on the table view. We should think about preparing all of these associations (package the entire feeditem in notifications) to avoid passsing a feedItem that is nil. If we set self.feedItem after this has been called, the NSFRC will be in a bad state and must be setup again. 
    request.predicate = [NSPredicate predicateWithFormat:@"feedItem = %@", self.feedItem];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"Checkin"]) {
        ApplicatonNavigationController *nc = (ApplicatonNavigationController *)[segue destinationViewController];
        nc.isChildNavigationalStack = YES;
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"ShowLikers"]) {
        UsersListViewController *vc = [segue destinationViewController];
        vc.usersList = self.feedItem.liked;
        vc.includeFindFriends = NO;
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
        vc.list_title = NSLocalizedString(@"LIKERS_TITLE", "Title for likers table");
    } else if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UserViewController *vc = (UserViewController *) [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
        vc.user = (User *)sender;
    }
}

- (void)updateFeedItem {
    ALog(@"updating feed item %@", self.feedItem.externalId);
    [self.managedObjectContext performBlock:^{
        [RestFeedItem loadByIdentifier:self.feedItem.externalId onLoad:^(RestFeedItem *restFeedItem) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
            NSError *error;
            [self.managedObjectContext save:&error];
            //[self saveContext];
            
            [self setupFetchedResultsController];
            [self setupView];
        } onError:^(NSError *error) {
            ALog(@"There was a problem loading new comments: %@", error);
        }];

    }];
}


- (void)setupFooterView {
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 20, self.view.frame.size.width, 40.0)];
    //view.clipsToBounds = NO;
    
    self.footerView.opaque = YES;
    self.footerView.backgroundColor = RGBCOLOR(239.0, 239.0, 239.0);
    [self.footerView.layer setMasksToBounds:NO];
    //[self.footerView.layer setBorderColor: [[UIColor redColor] CGColor]];
    //[self.footerView.layer setBorderWidth: 1.0];
    //[self.footerView.layer setShadowColor:[UIColor blackColor].CGColor];
    //[self.footerView.layer setShadowOffset:CGSizeMake(0, 0)];
    //[self.footerView.layer setShadowRadius:2.0];
    //[self.footerView.layer setShadowOpacity:0.65 ];
    //[self.footerView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.footerView.bounds ] CGPath ] ];
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0, 5.0, 220.0, 43.0)];
    textView.delegate = self;
    self.commentView = textView;
    self.commentView.text = NSLocalizedString(@"ENTER_COMMENT", nil);
    self.commentView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.commentView.textColor = RGBCOLOR(127, 127, 127);
    [self.commentView.layer setBorderColor:RGBCOLOR(233, 233, 233).CGColor];
    [self.commentView.layer setBorderWidth:1.0];
    [self.commentView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.commentView.layer setShadowOpacity:1 ];
    [self.commentView.layer setShadowRadius:4.0];
    [self.commentView.layer setShadowColor:RGBCOLOR(233, 233, 233).CGColor];
    [self.commentView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.commentView.bounds ] CGPath ] ];
    self.commentView.backgroundColor  = [UIColor clearColor];
    [self.footerView addSubview:textView];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(225.0, 5, 90.0, 43.0);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    //[enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateNormal];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateHighlighted];
    [enterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
    [enterButton setTitleColor:RGBCOLOR(117, 117, 117) forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(didAddComment:event:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:enterButton];
}

#pragma mark - UITableViewDelegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *identifier = @"NewCommentCell";
    NewCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NewCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if ([cell.profilePhotoView.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressProfilePhoto:)];
        [cell.profilePhotoView addGestureRecognizer:tapProfile];
    }
    
    cell.profilePhotoView.tag = indexPath.row;

    
    cell.timeInWordsLabel.backgroundColor = [UIColor backgroundColor];
    cell.userCommentLabel.backgroundColor = [UIColor backgroundColor];
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = comment.user.fullName;
    cell.userCommentLabel.text = comment.comment;
    
    //cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    //ALog(@"string is %@", fullString);
    CGSize expectedCommentLabelSize = [comment.comment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)];
    int height = MAX(expectedCommentLabelSize.height, 25);
    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, height)];
    
    
       
    ALog(@"recomed: %f,%f  actual: %f,%f", expectedCommentLabelSize.height, expectedCommentLabelSize.width, cell.userCommentLabel.frame.size.height, cell.userCommentLabel.frame.size.width);
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    
    [cell.timeInWordsLabel sizeToFit];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, (cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height) + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height + 4.0)];
    [cell.profilePhotoView setProfileImageForUser:comment.user];
    
    return cell;
}

#warning add constants
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"COMMENT IS %@", comment.comment);
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, COMMENT_LABEL_WIDTH, CGFLOAT_MAX)];
    sampleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    sampleLabel.text = [NSString stringWithFormat:@"%@", comment.comment];
    
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                   constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)                                                       lineBreakMode:UILineBreakModeWordWrap];
  
    
    DLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    int totalHeight;
    totalHeight = 24 + expectedCommentLabelSize.height + 2 + 16 + 6;;
    
    DLog(@"total height %d", totalHeight);
    return totalHeight;

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
               //add code here for when you hit delete
        [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_COMMENT", nil) maskType:SVProgressHUDMaskTypeGradient];
        [comment deleteComment:^(RestFeedItem *restFeedItem) {
            [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
            [self saveContext];
            [SVProgressHUD dismiss];
        } onError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"DELETE_COMMENT_FAILED", nil)];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.currentUser == comment.user) {
        return YES;
    }
    return NO;
}

#pragma mark - User actions
- (IBAction)didAddComment:(id)sender event:(UIEvent *)event {
    [self.commentView resignFirstResponder];
    NSString *comment = [self.commentView.text removeNewlines];
    if (comment.length == 0 || [comment isEqualToString:NSLocalizedString(@"ENTER_COMMENT", nil)]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"COMMENT_REQUIRED", @"User pressed submit with no comment given")];
        return;
    }
    
    [SVProgressHUD show];
    [Flurry logEvent:@"COMMENT_FROM_COMMENTS_PAGE"];
    [self.feedItem createComment:comment onLoad:^(RestComment *restComment) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableFooterView = nil;
        [self.feedItem addCommentsObject:comment];
        [self saveContext];
        [SVProgressHUD dismiss];
        self.commentView.text = nil;
        DLog(@"added comment");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchedResultsController.fetchedObjects count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } onError:^(NSError *error) {
        DLog(@"ERROR %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (IBAction)didPressProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    DLog(@"feed item from didPress is %@", feedItem.checkin.user.fullName);
    
    [self performSegueWithIdentifier:@"UserShow" sender:comment.user];
}


- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    
    DLog(@"ME LIKED IS %d", [self.feedItem.meLiked integerValue]);
    [Flurry logEvent:@"LIKE_FROM_COMMENTS"];

    if ([self.feedItem.meLiked boolValue]) {
        //Update the UI now
        self.feedItem.numberOfLikes = [NSNumber numberWithInteger:([self.feedItem.numberOfLikes integerValue] - 1)];
        self.feedItem.meLiked = [NSNumber numberWithBool:NO];
        
        [self.feedItem removeLikedObject:self.currentUser];
        [self setupView];
        [self.feedItem unlike:^(RestFeedItem *restFeedItem) {
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
            [self saveContext];
            [self setupView];
        } onError:^(NSError *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            self.feedItem.meLiked = [NSNumber numberWithBool:YES];
            self.feedItem.numberOfLikes = [NSNumber numberWithInteger:([self.feedItem.numberOfLikes integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            [self setupView];
            
        }];
    } else {
        //Update the UI so the responsiveness seems fast
        self.feedItem.numberOfLikes = [NSNumber numberWithInteger:([self.feedItem.numberOfLikes integerValue] + 1)];
        self.feedItem.meLiked = [NSNumber numberWithBool:YES];
        [self.feedItem addLikedObject:self.currentUser];
        [self setupView];
        [self.feedItem like:^(RestFeedItem *restFeedItem)
         {
             [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
             [self saveContext];
             [self setupView];
         }
                    onError:^(NSError *error)
         {
             // Request failed, we need to back out the temporary chagnes we made
             self.feedItem.numberOfLikes = [NSNumber numberWithInteger:([self.feedItem.numberOfLikes integerValue] - 1)];
             self.feedItem.meLiked = [NSNumber numberWithBool:NO];
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             [self setupView];
             
         }];
    }
}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            ALog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setViewMovedUp:NO kbSize:kbSize.height];
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        int index = [[self.fetchedResultsController fetchedObjects] count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
        CGRect lastRowRect = [self.tableView rectForRowAtIndexPath:indexPath];
        CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
        //[self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, contentHeight)];
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    DLog(@"keyboard shown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //[self.tableView setContentOffset:CGPointMake(0.0, kbSize.height + 100.0)];
    [self setViewMovedUp:YES kbSize:kbSize.height];
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        int index = [[self.fetchedResultsController fetchedObjects] count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
        CGRect lastRowRect = [self.tableView rectForRowAtIndexPath:indexPath];
        CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height + kbSize.height;
        //[self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, contentHeight)];
    }    
}

-(void)setViewMovedUp:(BOOL)movedUp kbSize:(float)kbSize
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.footerView.frame;
    if (movedUp)
    {
        DLog(@"KEYBOARD SHOWN AND MOVING UP ORIGIN %f", kbSize);
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kbSize;
         //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + kbSize)];
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - kbSize)];
        //rect.size.height += kbSize;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kbSize;
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + kbSize)];
        //[self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - kbSize)];
        //rect.size.height -= kbSize;
    }
    self.footerView.frame = rect;
    
    
    NSIndexPath *path = [self.fetchedResultsController indexPathForObject:[[self.fetchedResultsController fetchedObjects] lastObject]];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [UIView commitAnimations];
}

#pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
}

- (void)didCanceledCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
}

- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

#pragma mark - HPGrowingTextView delegate methods
-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    DLog(@"new height is %f old height is %f", height, self.footerView.frame.size.height);
    if(height < 50)
        height = 50.0;
    [self.footerView setFrame:CGRectMake(self.footerView.frame.origin.x, self.footerView.frame.origin.y - (height - self.footerView.frame.size.height ), self.footerView.frame.size.width, height)];
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if ([self.commentView.text isEqualToString:NSLocalizedString(@"ENTER_COMMENT", nil)]) {
        self.commentView.text = @"";
    }
    DLog(@"did begin editing");
}


#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}



@end
