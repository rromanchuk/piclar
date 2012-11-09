//
//  CheckinViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "CheckinViewController.h"
#import <QuartzCore/QuartzCore.h>

//Controllers
#import "LikesShowViewController.h"

// Categories
#import "NSDate+Formatting.h"

// CoreData Models
#import "Checkin+Rest.h"
#import "Photo.h"
#import "Comment+Rest.h"
#import "FeedItem+Rest.h"
#import "Notification.h"
#import "Checkin.h"
#import "Place.h"
#import "Comment.h"

// Rest models
#import "RestFeedItem.h"

// Views
#import "NewCommentCell.h"
#import "BaseView.h"

// Others
#import "Utils.h"

#define COMMENT_LABEL_WIDTH 253.0f
#define REVIEW_LABEL_WIDTH 297.0f
#define MINIMUM_Y_OFFSET 397.0f
#define MINIMUM_CELL_HEIGHT 54.0f

@interface CheckinViewController () {
    NSMutableArray *likerViews;
}
@property (nonatomic) BOOL beganUpdates;

@end

@implementation CheckinViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
        likerViews = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - ViewController lifecycle
- (void)viewDidLoad
{
    //self.footerView.hidden = YES;
    self.tableView.backgroundView = [[BaseView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    [self setupFooterView];
    
    // If native pull to refresh is available, use it.
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(updateFeedItem)
                 forControlEvents:UIControlEventValueChanged];
        //self.refreshControl = refreshControl;
    }

    [super viewDidLoad];
    
}

- (void)viewDidUnload {
    [self setFooterView:nil];
    [self setHeaderView:nil];
    [self setLikeButton:nil];
    [self setLikersView:nil];
    [self setDisclosureIndicator:nil];
    [super viewDidUnload];
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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.view.layer setCornerRadius:0.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    if(self.notification) { // Check if we are coming from notifications
        self.title = self.notification.placeTitle;
        DLog(@"coming from notification");
        FeedItem *feedItem = [FeedItem feedItemWithExternalId:self.notification.feedItemId inManagedObjectContext:self.managedObjectContext];
        if(feedItem) { // make sure this notification knows about its associated feed tiem
            DLog(@"got feed item %@", feedItem);
            self.feedItem = feedItem;
            [self setupView];
        } else {
            UIView *back_view = [[UIView alloc] initWithFrame:self.view.frame];
            back_view.backgroundColor = self.view.backgroundColor;
            [self.view addSubview:back_view];

            // For whatever reason CoreData doesn't know about this feedItem, we need to pull it form the server and build it
            [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
            [RestFeedItem loadByIdentifier:self.notification.feedItemId onLoad:^(RestFeedItem *restFeedItem) {
                FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                self.feedItem = feedItem;
                // we just replaced self.feedItem, we need to reinstantiate the fetched results controller since it is now most likely invalid
                [self setupFetchedResultsController];
                [self saveContext];
                [SVProgressHUD dismiss];
                [self setupView];
                [back_view removeFromSuperview];
            } onError:^(NSString *error) {
#warning crap, we couldn't load the feed item, we should show the error "try again" screen here...since this experience will be broken
                [SVProgressHUD showErrorWithStatus:error];
            }];
            
        }
    } else {
        // This is a normal segue from the feed, we don't have to do anything special here
        [self setupView];
    }
    [self updateFeedItem];

}

#pragma mark - view setup methods

- (void)setupView {
    self.title = self.feedItem.checkin.place.title;
    [self.profileImage setProfileImageForUser:self.feedItem.user];
    self.placeTypeImage.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
    [self.checkinPhoto setCheckinPhotoWithURL:[self.feedItem.checkin firstPhoto].url];
    self.dateLabel.text = [self.feedItem.checkin.createdAt distanceOfTimeInWords];
    self.reviewLabel.text = self.feedItem.checkin.review;
    [self setupDynamicElements];
    [self setStars:[self.feedItem.checkin.userRating integerValue]];
    
    // Set title attributed label
    NSString *text;
    text = [NSString stringWithFormat:@"%@ %@ %@", self.feedItem.user.normalFullName, NSLocalizedString(@"WAS_AT", nil), self.feedItem.checkin.place.title];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.titleLabel.textColor = RGBCOLOR(93, 93, 93);
    self.titleLabel.numberOfLines = 2;
    if (self.feedItem.user.fullName && self.feedItem.checkin.place.title) {
        
        [self.titleLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            NSRange boldNameRange = [[mutableAttributedString string] rangeOfString:self.feedItem.user.normalFullName options:NSCaseInsensitiveSearch];
            NSRange boldPlaceRange = [[mutableAttributedString string] rangeOfString:self.feedItem.checkin.place.title options:NSCaseInsensitiveSearch];
            
            UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldNameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldPlaceRange];
            CFRelease(font);
            
            return mutableAttributedString;
        }];
        
    }
    
#warning create a custom view for this
    if ([self.feedItem.meLiked boolValue]) {
        self.likeButton.selected = YES;
    } else {
        self.likeButton.selected = NO;
    }

    [self.likeButton setTitle:[self.feedItem.favorites stringValue] forState:UIControlStateNormal];
    [self.likeButton setTitle:[self.feedItem.favorites stringValue] forState:UIControlStateSelected];
    [self.likeButton setTitle:[self.feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    [self.likeButton setFrame:CGRectMake(self.reviewLabel.frame.origin.x, (self.reviewLabel.frame.origin.y + self.reviewLabel.frame.size.height) + 5, self.likeButton.frame.size.width, self.likeButton.frame.size.height)];
    
    
    for (ProfilePhotoView *view in likerViews) {
        [view removeFromSuperview];
    }
    likerViews = [[NSMutableArray alloc] init];
    
    [self.likersView setFrame:CGRectMake(self.likersView.frame.origin.x, (self.reviewLabel.frame.origin.y + self.reviewLabel.frame.size.height) + 5, self.likersView.frame.size.width, self.likersView.frame.size.height)];
    
    int xOffset = 10;
    for (User *liker in self.feedItem.liked) {
        ProfilePhotoView *likerPhoto = [[ProfilePhotoView alloc] initWithFrame:CGRectMake(xOffset, 2, 36, 36)];
        [likerPhoto setProfileImageForUser:liker];
        likerPhoto.tag = 99;
        [likerViews addObject:likerPhoto];
        [self.likersView addSubview:likerPhoto];
        xOffset = (xOffset + 36) + 5;
    }
    
    if ([self.feedItem.liked count] == 0) {
        self.disclosureIndicator.hidden = YES;
        self.likersView.userInteractionEnabled = NO;
    } else {
        self.disclosureIndicator.hidden = NO;
        self.likersView.userInteractionEnabled = YES;
    }
    [self setupFetchedResultsController];
    
}


- (void)setupDynamicElements {
    CGSize expectedCommentLabelSize = [self.reviewLabel.text sizeWithFont:self.reviewLabel.font
                                                             constrainedToSize:CGSizeMake(REVIEW_LABEL_WIDTH, CGFLOAT_MAX)
                                                                 lineBreakMode:UILineBreakModeWordWrap];
    [self.reviewLabel setFrame:CGRectMake(self.reviewLabel.frame.origin.x, self.reviewLabel.frame.origin.y, REVIEW_LABEL_WIDTH, expectedCommentLabelSize.height)];
    self.reviewLabel.numberOfLines = 0;
    [self.reviewLabel sizeToFit];
    //self.reviewLabel.backgroundColor = [UIColor redColor];
    
    [self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, expectedCommentLabelSize.height + MINIMUM_Y_OFFSET + (self.likeButton.frame.size.height + 5))];
    
    //[self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, 600)];

    //self.headerView.backgroundColor = [UIColor yellowColor];
}


#warning create custom view class for this
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


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   if ([[segue identifier] isEqualToString:@"ShowLikers"]) {
        LikesShowViewController *vc = [segue destinationViewController];
        vc.feedItem = self.feedItem;
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    }

}


#pragma mark - FRC setup
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



#pragma mark - UITableViewController delegate methods
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
    cell.userCommentLabel.textColor = RGBCOLOR(93, 93, 93);
    
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
    
    DLog(@"string is %@", cell.userCommentLabel.text);
    CGSize expectedCommentLabelSize = [fullString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0] constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)];
//    CGSize expectedCommentLabelSize = [fullString sizeWithFont:cell.userCommentLabel.font
//                                                             constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)
//                                                                 lineBreakMode:UILineBreakModeWordWrap];
    int height = MAX(expectedCommentLabelSize.height, 20);
    [cell.userCommentLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, cell.userCommentLabel.frame.origin.y, COMMENT_LABEL_WIDTH, height)];
    cell.userCommentLabel.numberOfLines = 0;
    [cell.userCommentLabel sizeToFit];
    //cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    DLog(@"recomed: %f,%f  actual: %f,%f", expectedCommentLabelSize.height, expectedCommentLabelSize.width, cell.userCommentLabel.frame.size.height, cell.userCommentLabel.frame.size.width);
    if (cell.userCommentLabel.frame.size.height < 18) {
        CGRect frame = cell.userCommentLabel.frame;
        frame.size.height = 19;
        cell.userCommentLabel.frame = frame;
    }
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    
    [cell.timeInWordsLabel sizeToFit];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, (cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height) + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height + 4.0)];
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
    sampleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    sampleLabel.text = [NSString stringWithFormat:@"%@ %@", comment.user.normalFullName, comment.comment];
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                   constrainedToSize:CGSizeMake(COMMENT_LABEL_WIDTH, CGFLOAT_MAX)                                                       lineBreakMode:UILineBreakModeWordWrap];
    
    DLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
    int totalHeight;
    //sampleLabel.
    totalHeight = 12 + expectedCommentLabelSize.height + 2 + 16 + 6;;
    
    DLog(@"total height %d", totalHeight);
    return totalHeight;
}




- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            ALog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#warning not dry, exists in FeedCell.m
- (void)setStars:(NSInteger)stars {
    self.star1.highlighted = YES;
    self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = NO;
    if (stars == 5) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = self.star5.highlighted = YES;
    } else if (stars == 4) {
        self.star2.highlighted = self.star3.highlighted = self.star4.highlighted = YES;
    } else if (stars == 3) {
        self.star2.highlighted = self.star3.highlighted = YES;
    } else {
        self.star2.highlighted = YES;
    }
}

#pragma mark - HPGrowingTextView delegate methods
-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    DLog(@"new height is %f old height is %f", height, self.footerView.frame.size.height);
    if(height < 40)
        height = 40.0;
    [self.footerView setFrame:CGRectMake(self.footerView.frame.origin.x, self.footerView.frame.origin.y - (height - self.footerView.frame.size.height ), self.footerView.frame.size.width, height)];
}





#pragma mark - User actions
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchedResultsController.fetchedObjects count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    } onError:^(NSString *error) {
        DLog(@"ERROR %@", error);
        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (IBAction)didLike:(id)sender event:(UIEvent *)event {

    DLog(@"ME LIKED IS %d", [self.feedItem.meLiked integerValue]);
    if ([self.feedItem.meLiked boolValue]) {
        //Update the UI now
        self.feedItem.favorites = [NSNumber numberWithInteger:([self.feedItem.favorites integerValue] - 1)];
        self.feedItem.meLiked = [NSNumber numberWithBool:NO];
        
        [self.feedItem removeLikedObject:self.currentUser];
        [self setupView];
        [self.feedItem unlike:^(RestFeedItem *restFeedItem) {
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
            [self saveContext];
            [self setupView];
        } onError:^(NSString *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            self.feedItem.meLiked = [NSNumber numberWithBool:YES];
            self.feedItem.favorites = [NSNumber numberWithInteger:([self.feedItem.favorites integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error];
            [self setupView];

        }];
    } else {
        //Update the UI so the responsiveness seems fast
        self.feedItem.favorites = [NSNumber numberWithInteger:([self.feedItem.favorites integerValue] + 1)];
        self.feedItem.meLiked = [NSNumber numberWithBool:YES];
        [self.feedItem addLikedObject:self.currentUser];
        [self setupView];
        [self.feedItem like:^(RestFeedItem *restFeedItem)
         {
             DLog(@"saving favorite counts with %d", restFeedItem.favorites);
             [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
             [self saveContext];
             [self setupView];
         }
               onError:^(NSString *error)
         {
             // Request failed, we need to back out the temporary chagnes we made
             self.feedItem.favorites = [NSNumber numberWithInteger:([self.feedItem.favorites integerValue] - 1)];
             self.feedItem.meLiked = [NSNumber numberWithBool:NO];
             [SVProgressHUD showErrorWithStatus:error];
             [self setupView];

         }];
    }
}

- (IBAction)didClickLikers:(id)sender {
    [self performSegueWithIdentifier:@"ShowLikers" sender:self];
}


- (IBAction)didPressProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"feed item from didPress is %@", feedItem.checkin.user.normalFullName);
    
    [self performSegueWithIdentifier:@"UserShow" sender:feedItem.checkin.user];
    ALog(@"building collection view");
}

- (void)updateFeedItem {
    [RestFeedItem loadByIdentifier:self.feedItem.externalId onLoad:^(RestFeedItem *_feedItem) {
        [FeedItem feedItemWithRestFeedItem:_feedItem inManagedObjectContext:self.managedObjectContext];
        [self saveContext];
        [self setupFetchedResultsController];
        [self setupView];
        [self endPullToRefresh];
    } onError:^(NSString *error) {
        DLog(@"There was a problem loading new comments: %@", error);
    }];
}

- (void)endPullToRefresh {
    if ([UIRefreshControl class]) {
        //[self.refreshControl endRefreshing];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_COMMENT", nil) maskType:SVProgressHUDMaskTypeGradient];
        [comment deleteComment:^(RestFeedItem *restFeedItem) {
            [self.feedItem updateFeedItemWithRestFeedItem:restFeedItem];
            [self saveContext];
            [SVProgressHUD dismiss];
        } onError:^(NSString *error) {
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



- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self setViewMovedUp:NO kbSize:kbSize.height];
    
    if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
        int index = [[self.fetchedResultsController fetchedObjects] count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
        CGRect lastRowRect = [self.tableView rectForRowAtIndexPath:indexPath];
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
        CGRect lastRowRect = [self.tableView rectForRowAtIndexPath:indexPath];
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


@end
