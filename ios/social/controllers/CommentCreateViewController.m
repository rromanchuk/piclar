//
//  CommentCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//


// Controllers
#import "LikesShowViewController.h"
#import "BaseNavigationViewController.h"
#import "CommentCreateViewController.h"


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

// Views
#import "BaseView.h"
#import "NewCommentCell.h"

#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

#define COMMENT_LABEL_WIDTH 237.0f
#define REVIEW_COMMENT_LABEL_WIDTH 253.0f
#define HEADER_HEIGHT 74.0f

@interface CommentCreateViewController ()
@property (nonatomic) BOOL beganUpdates;

@end

@implementation CommentCreateViewController
@synthesize managedObjectContext;
@synthesize feedItem;
@synthesize commentView;
@synthesize footerView;
@synthesize headerView;
@synthesize tableView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"LEAVE_A_COMMENT", @"Title for leaving a comment");
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: backButtonItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    
    [self setupFooterView];
}

- (NSString *)buildCommentersString {
    NSMutableArray *likers = [[NSMutableArray alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    if ([self.feedItem.liked count] > 0) {
        for (User *user in self.feedItem.liked) {
            DLog(@"found commment %@", user.normalFullName);
            [likers addObject:user.normalFullName];
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
        copy = [NSString stringWithFormat:@"%@, %@, %@ %@ 1 %@ %@.", [names objectAtIndex:0], [names objectAtIndex:1], NSLocalizedString(@"AND", nil), [names objectAtIndex:2],  NSLocalizedString(@"OTHER", nil), NSLocalizedString(@"SINGULAR_LIKES_THIS", nil)];
    } else if (totalLikers > 4) {
        //<name1>, <name2>, <name3> and 2 others like this
        int remainingLikers = totalLikers - 3;
        copy = [NSString stringWithFormat:@"%@, %@, %@, %@ %d %@ %@.", [names objectAtIndex:0], [names objectAtIndex:1], [names objectAtIndex:2], NSLocalizedString(@"AND", nil), remainingLikers, NSLocalizedString(@"OTHERS", nil), NSLocalizedString(@"PLURAL_LIKE_THIS", nil)];

    }

    return copy;
}

- (void)setupView {
    if ([self.feedItem.liked count] > 0) {
        [self.headerView setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, HEADER_HEIGHT)];
        self.headerView.hidden = NO;
        self.likeLabel.text = [self buildCommentersString];
    } else {
        [self.headerView setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, 0)];
        self.headerView.hidden = YES;

    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [self setFooterView:nil];
    [self setHeaderView:nil];
    [self setTableView:nil];
    [self setLikeLabel:nil];
    [self setDisclosureIndicator:nil];
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
    
    if(self.notification) { // Check if we are coming from notifications 
        if(self.notification.feedItem) { // make sure this notification knows about its associated feed tiem
            self.feedItem = self.notification.feedItem;
        } else {
            // For whatever reason CoreData doesn't know about this feedItem, we need to pull it form the server and build it
            [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
            [RestNotification loadByIdentifier:self.notification.externalId onLoad:^(RestNotification *restNotification) {
                [self.notification updateNotificationWithRestNotification:restNotification];
                DLog(@"updated notification %@", self.notification);
                self.feedItem = self.notification.feedItem;
                // we just replaced self.feedItem, we need to reinstantiate the fetched results controller since it is now most likely invalid
                [self setupFetchedResultsController];
                [self saveContext];
                [SVProgressHUD dismiss];
            } onError:^(NSString *error) {
#warning crap, we couldn't load the feed item, we should show the error "try again" screen here...since this experience will be broken 
                [SVProgressHUD showErrorWithStatus:error];
            }];
            
        }
    } else {
        // This is a normal segue from the feed, we don't have to do anything special here
    }
    
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
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"ShowLikers"]) {
        LikesShowViewController *vc = [segue destinationViewController];
        vc.feedItem = self.feedItem;
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    }
}

- (void)updateFeedItem {
    [RestFeedItem loadByIdentifier:self.feedItem.externalId onLoad:^(RestFeedItem *_feedItem) {
        [self.feedItem updateFeedItemWithRestFeedItem:_feedItem];
        [self saveContext];
        [self setupFetchedResultsController];
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"There was a problem loading new comments: %@", error);
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
    [self.footerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.footerView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.footerView.layer setShadowRadius:2.0];
    [self.footerView.layer setShadowOpacity:0.65 ];
    [self.footerView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.footerView.bounds ] CGPath ] ];
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    textView.delegate = self;
    self.commentView = textView;
    [self.commentView.layer setBorderColor:RGBCOLOR(233, 233, 233).CGColor];
    [self.commentView.layer setBorderWidth:1.0];
    [self.commentView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.commentView.layer setShadowOpacity:1 ];
    [self.commentView.layer setShadowRadius:4.0];
    [self.commentView.layer setShadowColor:RGBCOLOR(233, 233, 233).CGColor];
    [self.commentView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.commentView.bounds ] CGPath ] ];
    [self.footerView addSubview:textView];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(245.0, 6.0, 70.0, 28.0);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    //[enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateNormal];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateHighlighted];
    [enterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
    [enterButton setTitleColor:RGBCOLOR(117, 117, 117) forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(didAddComment:event:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:enterButton];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *identifier = @"NewCommentCell";
    NewCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NewCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *nameText = comment.user.normalFullName;
    NSString *commentText = comment.comment;
    NSString *fullString = [NSString stringWithFormat:@"%@ %@", nameText, commentText];
    
    
    if (nameText && commentText) {
        
        [cell.userCommentLabel setText:fullString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange boldNameRange = [[mutableAttributedString string] rangeOfString:nameText options:NSCaseInsensitiveSearch];
            
            UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldNameRange];
            CFRelease(font);
            
            return mutableAttributedString;
        }];
        
    }

    
    
    CGSize expectedCommentLabelSize = [cell.userCommentLabel.text sizeWithFont:cell.userCommentLabel.font
                                                             constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)
                                                                 lineBreakMode:UILineBreakModeWordWrap];

    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, expectedCommentLabelSize.height)];
    cell.userCommentLabel.numberOfLines = 0;
    [cell.userCommentLabel sizeToFit];
    //cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, (cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height) + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height)];
    //cell.timeInWordsLabel.backgroundColor = [UIColor greenColor];
    [cell.profilePhotoView setProfileImageWithUrl:comment.user.remoteProfilePhotoUrl];
    
    return cell;
}

#warning add constants
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"COMMENT IS %@", comment.comment);
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, COMMENT_LABEL_WIDTH, CGFLOAT_MAX)];
    sampleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    sampleLabel.text = comment.comment;
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                   constrainedToSize:sampleLabel.frame.size
                                                       lineBreakMode:UILineBreakModeWordWrap];
    
    DLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    
    return  12 + expectedCommentLabelSize.height + 2 + 16 + 12;
}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//    }
//}


- (IBAction)didAddComment:(id)sender event:(UIEvent *)event {
    [self.commentView resignFirstResponder];
    NSString *comment = [self.commentView.text removeNewlines];
    if (comment.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"COMMENT_REQUIRED", @"User pressed submit with no comment given")];
        return;
    }
    
    [SVProgressHUD show];
    [self.feedItem createComment:comment onLoad:^(RestComment *restComment) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
        [self.feedItem addCommentsObject:comment];
        [self saveContext];
        [SVProgressHUD dismiss];
        self.commentView.text = nil;
        DLog(@"added comment");
    } onError:^(NSString *error) {
        DLog(@"ERROR %@", error);
        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
        CGRect lastRowRect = [tableView rectForRowAtIndexPath:indexPath];
        CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height;
        [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, contentHeight)];
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
        CGRect lastRowRect = [tableView rectForRowAtIndexPath:indexPath];
        CGFloat contentHeight = lastRowRect.origin.y + lastRowRect.size.height + kbSize.height;
        [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, contentHeight)];
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
        //rect.size.height += kbSize;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kbSize;
        //rect.size.height -= kbSize;
    }
    self.footerView.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didCanceledCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

#pragma mark - HPGrowingTextView delegate methods
-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    DLog(@"new height is %f old height is %f", height, self.footerView.frame.size.height);
    if(height < 40)
        height = 40.0;
    [self.footerView setFrame:CGRectMake(self.footerView.frame.origin.x, self.footerView.frame.origin.y - (height - self.footerView.frame.size.height ), self.footerView.frame.size.width, height)];
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
