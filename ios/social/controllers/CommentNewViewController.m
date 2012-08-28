//
//  CommentNewViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
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
@interface CommentNewViewController ()

@end

@implementation CommentNewViewController
@synthesize backButton;
@synthesize managedObjectContext;
@synthesize feedItem;
@synthesize placeTypePhoto;
@synthesize placeTitleLabel;
@synthesize placeTypeLabel;
@synthesize footer;
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
    self.title = NSLocalizedString(@"LEAVE_A_COMMENT", @"Title for leaving a comment");
    [self.navigationController.view.layer setCornerRadius:0.0];
    self.navigationItem.hidesBackButton = YES;
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];

    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: fixed, self.backButton, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    self.placeTypePhoto.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
    self.placeTitleLabel.text = self.feedItem.checkin.place.title;
    self.placeTypeLabel.text = self.feedItem.checkin.place.type;
    self.footer = [self footerView];
    [[self parentViewController].view addSubview:self.footer];
    if (self.feedItem.comments == 0)
        [self.commentView becomeFirstResponder];
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchResults];
    [self setupFetchedResultsController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.commentView resignFirstResponder];
    [self.footer removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                object:nil];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 20, self.view.frame.size.width, 40.0)];
    //view.clipsToBounds = NO;
    
    view.opaque = YES;
    view.backgroundColor = RGBCOLOR(239.0, 239.0, 239.0);
    [view.layer setMasksToBounds:NO];
    [view.layer setBorderColor: [[UIColor redColor] CGColor]];
    [view.layer setBorderWidth: 1.0];
    [view.layer setShadowColor:[UIColor blackColor].CGColor];
    [view.layer setShadowOffset:CGSizeMake(0, 0)];
    [view.layer setShadowRadius:4.0];
    [view.layer setShadowOpacity:0.65 ];
    [view.layer setShadowPath:[[UIBezierPath bezierPathWithRect:view.bounds ] CGPath ] ];
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    textView.delegate = self;
    self.commentView = textView;
    //        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(5.0, 5.0, 232.0, 30.0)];
    //        textField.borderStyle = UITextBorderStyleLine;
    //        textField.placeholder = NSLocalizedString(@"ENTER_COMMENT", @"Prompt asking for comment");
    //        self.commentTextField = textField;
    [view addSubview:textView];
    
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
    [view addSubview:enterButton];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
              
    
    NSString *identifier = @"NewCommentCell"; 
    NewCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NewCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *comment;
    NSString *name;
    NSString *timeAgoInWords;
    NSString *profileUrl;
    if(self.feedItem.checkin.review.length > 0 && indexPath.row == 0) {
        comment = self.feedItem.checkin.review;
        name = self.feedItem.checkin.user.normalFullName;
        profileUrl = self.feedItem.checkin.user.remoteProfilePhotoUrl;
        timeAgoInWords = [self.feedItem.checkin.createdAt distanceOfTimeInWords];
    } else{
        if (self.feedItem.checkin.review.length > 0) {
            indexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:0];
        }
        Comment *NScomment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        comment = NScomment.comment;
        name = NScomment.user.normalFullName;
        profileUrl = NScomment.user.remoteProfilePhotoUrl;
        timeAgoInWords = [NScomment.createdAt distanceOfTimeInWords];
    }
    
    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, 60.0)];
    cell.userNameLabel.text = name;
    
    cell.userCommentLabel.text = comment;
    NSLog(@"constraining to size %f", cell.userCommentLabel.frame.size.width);
    CGSize expectedCommentLabelSize = [cell.userCommentLabel.text sizeWithFont:cell.userCommentLabel.font
                                                        constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, 60.0)
                                                            lineBreakMode:UILineBreakModeWordWrap];
   
    CGRect commentLabelFrame = cell.userCommentLabel.frame;
    commentLabelFrame.size.height = expectedCommentLabelSize.height;
    cell.userCommentLabel.frame = commentLabelFrame;
    cell.userCommentLabel.numberOfLines = 0;
    [cell.userCommentLabel sizeToFit];
    cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    cell.timeInWordsLabel.text = timeAgoInWords;
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height)];
    cell.timeInWordsLabel.backgroundColor = [UIColor greenColor];
    //cell.commentView.backgroundColor = [UIColor grayColor];
    [cell.profilePhotoView setProfileImageWithUrl:profileUrl];
    
    CGRect commentFrame = cell.commentView.frame;
    commentFrame.size.height = cell.timeInWordsLabel.frame.origin.y + cell.timeInWordsLabel.frame.size.height + 5.0;
    cell.commentView.frame = commentFrame;
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSString *comment;
    NSString *name;
    NSString *timeAgoInWords;
    NSString *profileUrl;
    if(self.feedItem.checkin.review.length > 0 && indexPath.row == 0) {
        comment = self.feedItem.checkin.review;
        name = self.feedItem.checkin.user.normalFullName;
        profileUrl = self.feedItem.checkin.user.remoteProfilePhotoUrl;
        timeAgoInWords = [self.feedItem.checkin.createdAt distanceOfTimeInWords];
    } else{
        if (self.feedItem.checkin.review.length > 0) {
            indexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:0];
        }
        Comment *NScomment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        comment = NScomment.comment;
        name = NScomment.user.normalFullName;
        profileUrl = NScomment.user.remoteProfilePhotoUrl;
        timeAgoInWords = [NScomment.createdAt distanceOfTimeInWords];
    }

    
    
    
    
    //Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
   
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, COMMENT_LABEL_WIDTH, 60)];
    sampleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:11];
    sampleLabel.text = comment;
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                             constrainedToSize:sampleLabel.frame.size
                                                                 lineBreakMode:UILineBreakModeWordWrap];

    NSLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    return expectedCommentLabelSize.height + 55.0;
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
    [self.commentView resignFirstResponder];
    
    [SVProgressHUD show];
    [self.feedItem createComment:self.commentView.text onLoad:^(RestComment *restComment) {
        Comment *comment = [Comment commentWithRestComment:restComment inManagedObjectContext:self.managedObjectContext];
        [self.feedItem addCommentsObject:comment];
        [self saveContext];
        [SVProgressHUD dismiss];
        self.commentView.text = nil;
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

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setViewMovedUp:NO kbSize:kbSize.height];

}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"keyboard shown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setViewMovedUp:YES kbSize:kbSize.height];
}

-(void)setViewMovedUp:(BOOL)movedUp kbSize:(float)kbSize
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.footer.frame;
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
    self.footer.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - HPGrowingTextView delegate methods
-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    NSLog(@"new height is %f old height is %f", height, self.footer.frame.size.height);
    if(height < 40)
        height = 40.0;
    [self.footer setFrame:CGRectMake(self.footer.frame.origin.x, self.footer.frame.origin.y - (height - self.footer.frame.size.height ), self.footer.frame.size.width, height)];
}
@end
