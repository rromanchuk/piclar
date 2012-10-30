//
//  CheckinViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/19/12.
//
//

#import "CheckinViewController.h"
#import <QuartzCore/QuartzCore.h>
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

#define COMMENT_LABEL_WIDTH 253.0f
#define REVIEW_LABEL_WIDTH 297.0f
#define MINIMUM_Y_OFFSET 397.0f
#define MINIMUM_CELL_HEIGHT 54.0f

@interface CheckinViewController ()

@end

@implementation CheckinViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

#pragma mark - ViewController lifecycle
- (void)viewDidLoad
{
    //self.footerView.hidden = YES;
    [self setupFooterView];

    [super viewDidLoad];
    
}

- (void)viewDidUnload {
    [self setFooterView:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.notification) { // Check if we are coming from notifications
        DLog(@"coming from notification");
        FeedItem *feedItem = [FeedItem feedItemWithExternalId:self.notification.feedItemId inManagedObjectContext:self.managedObjectContext];
        if(feedItem) { // make sure this notification knows about its associated feed tiem
            DLog(@"got feed item %@", feedItem);
            self.feedItem = feedItem;
            [self setupView];
        } else {
            // For whatever reason CoreData doesn't know about this feedItem, we need to pull it form the server and build it
            [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
            [RestFeedItem loadByIdentifier:self.notification.feedItemId onLoad:^(RestFeedItem *restFeedItem) {
                FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                self.feedItem = feedItem;
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

}

- (void)setupView {
    self.title = self.feedItem.checkin.place.title;
    [self.profileImage setProfileImageForUser:self.feedItem.user];
    [self.checkinPhoto setCheckinPhotoWithURL:[self.feedItem.checkin firstPhoto].url];
    self.dateLabel.text = [self.feedItem.checkin.createdAt distanceOfTimeInWords];
    self.reviewLabel.text = self.feedItem.checkin.review;
    [self setupDynamicElements];
    [self setStars:[self.feedItem.checkin.userRating integerValue]];
    
    // Set title attributed label
    NSString *text;
    text = [NSString stringWithFormat:@"%@ %@ %@", self.feedItem.user.normalFullName, NSLocalizedString(@"WAS_AT", nil), self.feedItem.checkin.place.title];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.titleLabel.textColor = [UIColor blackColor];
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
    
    [self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, expectedCommentLabelSize.height + MINIMUM_Y_OFFSET)];
    
    //[self.headerView setFrame:CGRectMake(0, 0, self.headerView.frame.size.width, 600)];

    //self.headerView.backgroundColor = [UIColor yellowColor];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
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
    //cell.userCommentLabel.numberOfLines = 0;
    //[cell.userCommentLabel sizeToFit];
    //cell.userCommentLabel.backgroundColor = [UIColor yellowColor];
    
    DLog(@"recomed: %f,%f  actual: %f,%f", expectedCommentLabelSize.height, expectedCommentLabelSize.width, cell.userCommentLabel.frame.size.height, cell.userCommentLabel.frame.size.width);
    
    cell.timeInWordsLabel.text = [comment.createdAt distanceOfTimeInWords];
    
    [cell.timeInWordsLabel sizeToFit];
    [cell.timeInWordsLabel setFrame:CGRectMake(cell.userCommentLabel.frame.origin.x, (cell.userCommentLabel.frame.origin.y + cell.userCommentLabel.frame.size.height) + 2.0, cell.timeInWordsLabel.frame.size.width, cell.timeInWordsLabel.frame.size.height + 4.0)];
    cell.timeInWordsLabel.backgroundColor = [UIColor greenColor];
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
    } onError:^(NSString *error) {
        DLog(@"ERROR %@", error);
        [SVProgressHUD showErrorWithStatus:error];
    }];
}



@end
