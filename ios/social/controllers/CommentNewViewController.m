//
//  CommentNewViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
#define COMMENT_LABEL_WIDTH 250.0f
@interface CommentNewViewController ()

@end

@implementation CommentNewViewController
@synthesize backButton;
@synthesize managedObjectContext;
@synthesize feedItem;
@synthesize placeTypePhoto;
@synthesize placeTitleLabel;
@synthesize placeTypeLabel;
@synthesize commentTextField;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 //name:UIKeyboardWillHideNotification object:self.view.window];
    
    self.navigationItem.hidesBackButton = YES;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
    //self.tableView.tableFooterView = [self footerView];
	// Do any additional setup after loading the view.
    self.placeTitleLabel.text = self.feedItem.checkin.place.title;
    self.placeTypeLabel.text = self.feedItem.checkin.place.type;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"LEAVE_A_COMMENT", @"Title for leaving a comment");
    [self fetchResults];
    [self setupFetchedResultsController];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidUnload
{
    [self setBackButton:nil];
    [self setPlaceTypePhoto:nil];
    [self setPlaceTitleLabel:nil];
    [self setPlaceTypeLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"FeedItem = %@", self.feedItem];
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
    }
}


- (void)fetchResults {
    [RestFeedItem loadByIdentifier:self.feedItem.externalId onLoad:^(RestFeedItem *_feedItem) {
        for (RestComment *comment in _feedItem.comments) {
            [Comment commentWithRestComment:comment inManagedObjectContext:self.managedObjectContext];
        }
        
    } onError:^(NSString *error) {
        NSLog(@"There was a problem loading new comments: %@", error);
    }];
}

- (UIView *)footerView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 440.0, 320.0, 40.0)];
    view.backgroundColor = [UIColor grayColor];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    textField.borderStyle = UITextBorderStyleBezel;
    textField.placeholder = NSLocalizedString(@"ENTER_COMMENT", @"Prompt asking for comment");
    self.commentTextField = textField;
    [view addSubview:textField];
    
    //UIButton *enterButton = [[UIButton alloc] buttonType initWithFrame:CGRectMake(249.0, 8.0, 69.0, 25.0)];
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(249.0, 8.0, 69.0, 25.0);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
    [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateNormal];
    [enterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
    [enterButton addTarget:self action:@selector(didAddComment:event:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:enterButton];
    return view;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        CGRect footerFrame = [tableView rectForFooterInSection:section];
        UIView *view = [[UIView alloc] initWithFrame:footerFrame];
        view.backgroundColor = [UIColor grayColor];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
        textField.borderStyle = UITextBorderStyleBezel;
        textField.placeholder = NSLocalizedString(@"ENTER_COMMENT", @"Prompt asking for comment");
        self.commentTextField = textField;
        [view addSubview:textField];
        
        //UIButton *enterButton = [[UIButton alloc] buttonType initWithFrame:CGRectMake(249.0, 8.0, 69.0, 25.0)];
        UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        enterButton.frame = CGRectMake(249.0, 8.0, 70.0, 28.0);
        [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button.png"] forState:UIControlStateNormal];
        [enterButton setBackgroundImage:[UIImage imageNamed:@"enter-button-pressed.png"] forState:UIControlStateHighlighted];
        [enterButton setTitle:NSLocalizedString(@"ENTER", @"Enter button for comment") forState:UIControlStateNormal];
        [enterButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0]];
        [enterButton addTarget:self action:@selector(didAddComment:event:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:enterButton];
        return view;
    }
   }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *identifier = @"NewCommentCell"; 
    NewCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NewCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, 60.0)];
    cell.userNameLabel.text = comment.user.fullName;
    
    cell.userCommentLabel.text = comment.comment;
    NSLog(@"constraining to size %f", cell.userCommentLabel.frame.size.width);
    CGSize expectedCommentLabelSize = [cell.userCommentLabel.text sizeWithFont:cell.userCommentLabel.font
                                                        constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, 60.0)
                                                            lineBreakMode:UILineBreakModeWordWrap];
    CGRect commentFrame = cell.commentView.frame;
    commentFrame.size.height = expectedCommentLabelSize.height + 40.0;
    cell.commentView.frame = commentFrame;
    
    CGRect commentLabelFrame = cell.userCommentLabel.frame;
    commentLabelFrame.size.height = expectedCommentLabelSize.height;
    cell.userCommentLabel.frame = commentLabelFrame;
    
    cell.userCommentLabel.numberOfLines = 0;
    [cell.userCommentLabel sizeToFit];
    cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height)];
    cell.timeInWordsLabel.backgroundColor = [UIColor greenColor];
    cell.commentView.backgroundColor = [UIColor grayColor];
    [cell.profilePhotoView setProfileImageWithUrl:comment.user.remoteProfilePhotoUrl];
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

    NSLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    return expectedCommentLabelSize.height + 45.0;
}


- (UIButton *) makeDetailDisclosureButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *disclosureArrow = [UIImage imageNamed:@"disclosure-indicator.png"];
    button.frame = CGRectMake(0, 0, 30.0, 30.0);
    [button setBackgroundImage:disclosureArrow forState:UIControlStateNormal];
    [button addTarget: self
               action: @selector(accessoryButtonTapped:withEvent:)
     forControlEvents: UIControlEventTouchUpInside];
    
    return button ;
}


- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

- (IBAction)didAddComment:(id)sender event:(UIEvent *)event {
    [self.commentTextField resignFirstResponder];
    
    [SVProgressHUD show];
    [self.feedItem createComment:self.commentTextField.text onLoad:^(RestComment *restComment) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
        [self.feedItem addCommentsObject:comment];
        [self saveContext];
        [SVProgressHUD dismiss];
        self.commentTextField.text = nil;
        NSLog(@"added comment");
    } onError:^(NSString *error) {
        NSLog(@"ERROR %@", error);
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"keyboard shown");
    //[self.tableView setNeedsDisplay];
    //[self.tableView reloadData];
}
@end
