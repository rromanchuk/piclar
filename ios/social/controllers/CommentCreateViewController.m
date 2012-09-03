//
//  CommentCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//

#import "CommentCreateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CommentNewViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "NewCommentCell.h"
#import "Comment.h"
#import "User+Rest.h"
#import "NSDate+Formatting.h"
#import "RestFeedItem.h"
#import "Comment+Rest.h"
#import "FeedItem+Rest.h"
#import "UIImageView+AFNetworking.h"
#import "Place.h"
#import "Checkin.h"
#import "PlaceShowViewController.h"
#import "BaseView.h"
#import "BaseNavigationViewController.h"
#import "Utils.h"
#define COMMENT_LABEL_WIDTH 237.0f

@interface CommentCreateViewController ()
@property (nonatomic) BOOL beganUpdates;

@end

@implementation CommentCreateViewController
@synthesize managedObjectContext;
@synthesize feedItem;
@synthesize commentView;
@synthesize footerView;
@synthesize headerView;
@synthesize placeTitleLabel;
@synthesize placeTypeLabel;
@synthesize placeTypePhoto;
@synthesize tableView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;

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
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"LEAVE_A_COMMENT", @"Title for leaving a comment");
    [self.navigationController.view.layer setCornerRadius:0.0];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: fixed, backButtonItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    
    self.placeTypePhoto.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
    self.placeTitleLabel.text = self.feedItem.checkin.place.title;
    self.placeTypeLabel.text = self.feedItem.checkin.place.type;

    [self setupFooterView];
    [self fetchResults];
    [self setupFetchedResultsController];

}

- (void)viewDidUnload
{
    [self setFooterView:nil];
    [self setHeaderView:nil];
    [self setPlaceTitleLabel:nil];
    [self setPlaceTypeLabel:nil];
    [self setPlaceTypePhoto:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.feedItem.comments count] == 0)
        [self.commentView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.commentView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"feedItem = %@", self.feedItem];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceShowFromComment"])
    {
        PlaceShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = self.feedItem;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    }
}


- (void)fetchResults {
    [RestFeedItem loadByIdentifier:self.feedItem.externalId onLoad:^(RestFeedItem *_feedItem) {
        for (RestComment *comment in _feedItem.comments) {
            [Comment commentWithRestComment:comment inManagedObjectContext:self.managedObjectContext];
        }
        
    } onError:^(NSString *error) {
        DLog(@"There was a problem loading new comments: %@", error);
    }];
}



- (void)setupFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 20, self.view.frame.size.width, 40.0)];
    //view.clipsToBounds = NO;
    
    view.opaque = YES;
    view.backgroundColor = RGBCOLOR(239.0, 239.0, 239.0);
    [self.footerView.layer setMasksToBounds:NO];
    [self.footerView.layer setBorderColor: [[UIColor redColor] CGColor]];
    [self.footerView.layer setBorderWidth: 1.0];
    [self.footerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.footerView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.footerView.layer setShadowRadius:4.0];
    [self.footerView.layer setShadowOpacity:0.65 ];
    [self.footerView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:view.bounds ] CGPath ] ];
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    textView.delegate = self;
    self.commentView = textView;
    //        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    //        textField.borderStyle = UITextBorderStyleLine;
    //        textField.placeholder = NSLocalizedString(@"ENTER_COMMENT", @"Prompt asking for comment");
    //        self.commentTextField = textField;
    [self.footerView addSubview:textView];
    
    //UIButton *enterButton = [[UIButton alloc] buttonType initWithFrame:CGRectMake(249.0, 8.0, 69.0, 25.0)];
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(245.0, 8.0, 70.0, 28.0);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateNormal];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateHighlighted];
    [enterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
    [enterButton setTitleColor:RGBCOLOR(242.0, 95.0, 144.0) forState:UIControlStateNormal];
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
    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, 60.0)];
    cell.userNameLabel.text = comment.user.normalFullName;
    
    cell.userCommentLabel.text = comment.comment;
    DLog(@"constraining to size %f", cell.userCommentLabel.frame.size.width);
    CGSize expectedCommentLabelSize = [cell.userCommentLabel.text sizeWithFont:cell.userCommentLabel.font
                                                             constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, 60.0)
                                                                 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect commentLabelFrame = cell.userCommentLabel.frame;
    commentLabelFrame.size.height = expectedCommentLabelSize.height;
    cell.userCommentLabel.frame = commentLabelFrame;
    cell.userCommentLabel.numberOfLines = 0;
    [cell.userCommentLabel sizeToFit];
    //cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height)];
    //cell.timeInWordsLabel.backgroundColor = [UIColor greenColor];
    //cell.commentView.backgroundColor = [UIColor grayColor];
    [cell.profilePhotoView setProfileImageWithUrl:comment.user.remoteProfilePhotoUrl];
    
    CGRect commentFrame = cell.commentView.frame;
    commentFrame.size.height = cell.timeInWordsLabel.frame.origin.y + cell.timeInWordsLabel.frame.size.height + 5.0;
    cell.commentView.frame = commentFrame;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, COMMENT_LABEL_WIDTH, 60)];
    sampleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:11];
    sampleLabel.text = comment.comment;
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                   constrainedToSize:sampleLabel.frame.size
                                                       lineBreakMode:UILineBreakModeWordWrap];
    
    DLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    return expectedCommentLabelSize.height + 55.0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}


- (IBAction)didAddComment:(id)sender event:(UIEvent *)event {
    [self.commentView resignFirstResponder];
    
    [SVProgressHUD show];
    [self.feedItem createComment:[self.commentView.text removeNewlines] onLoad:^(RestComment *restComment) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
        [self.feedItem addCommentsObject:comment];
        [self saveContext];
        [SVProgressHUD dismiss];
        self.commentView.text = nil;
        DLog(@"added comment");
    } onError:^(NSString *error) {
        DLog(@"ERROR %@", error);
        [SVProgressHUD dismissWithError:error];
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
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    DLog(@"keyboard shown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //[self.tableView setContentOffset:CGPointMake(0.0, kbSize.height + 100.0)];
    [self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height + kbSize.height + 40.0)];
    [self setViewMovedUp:YES kbSize:kbSize.height];
}

-(void)setViewMovedUp:(BOOL)movedUp kbSize:(float)kbSize
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.footerView.frame;
    if (movedUp)
    {
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
