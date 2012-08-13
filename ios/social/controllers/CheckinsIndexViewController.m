
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
#import "Comment.h"
#import "UIImageView+AFNetworking.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
#import "BubbleCommentView.h"
#import "UserComment.h"
#import "ReviewBubble.h"
#import "NSDate+Formatting.h"
#import "PhotoNewViewController.h"
#define USER_COMMENT_MARGIN 0.0f
#define USER_COMMENT_WIDTH 251.0f
#define USER_COMMENT_PADDING 10.0f

#define POSTCARD_HEIGHT 250.0f
#define POSTCARD_MARGIN 13.0f

#define INITIAL_BUBBLE_Y_OFFSET 264.0f
#define BUBBLE_VIEW_X_OFFSET 60.0f
#define BUBBLE_VIEW_WIDTH 245.0f
static NSString *TEST = @"This is a really long string ot test dynamic resizing. The blue fux jumped over the fence and then ran around in circles many times";
@interface CheckinsIndexViewController ()

@end

@implementation CheckinsIndexViewController

@synthesize managedObjectContext;
@synthesize sampleCell;
@synthesize placeHolderImage;

- (id)initWithCoder:(NSCoder*)aDecoder 
{
    if(self = [super initWithCoder:aDecoder]) 
    {
        userCommentFont = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
        userCommentLabelSize = CGSizeMake(251.0f, 20000.0f);
        commentFont = [UIFont fontWithName:@"Helvetica Neue" size:11.0];
        commentsLabelSize = CGSizeMake(211.0f, 20000.0f);
        self.placeHolderImage = [UIImage imageNamed:@"placeholder.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissModal:)
                                                 name:@"dismissModal"
                                               object:nil];

    
    self.sampleCell = [[PostCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CheckinCell"];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    [self fetchResults];
      	// Do any additional setup after loading the view.
//    [RestCheckin createCheckinWithPlace:[NSNumber numberWithInt:1786] 
//                               andPhoto:[UIImage imageNamed:@"sample-photo1-show"]
//                             andComment:@"This is a test comment"
//                              andRating:4
//                                 onLoad:^(RestCheckin *checkin) {
//                                     NSLog(@"");
//                                 } 
//                                onError:^(NSString *error) {
//                                    NSLog(@"");
//                                }];

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
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceShow"])
    {
        PlaceShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        vc.feedItem = feedItem;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        PhotoNewViewController *vc = ((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentNewViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
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
    } else {
        // Remove manually added subviews from reused cells
        for (UIView *subview in [cell subviews]) {
            if (subview.tag == 999) {
                NSLog(@"Found a bubble comment, removing.");
                [subview removeFromSuperview];
            }
        }
    }
    
    
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
        
    
    //comments v2
    int commentNumber = 1;
    int yOffset = INITIAL_BUBBLE_Y_OFFSET;
    
    // Set the review bubble
    ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
    reviewComment.tag = 999;
    reviewComment.commentLabel.text = feedItem.checkin.review;
    CGSize expectedReviewLabelSize = [reviewComment.commentLabel.text sizeWithFont:userCommentFont
                                                         constrainedToSize:reviewComment.commentLabel.frame.size
                                                             lineBreakMode:UILineBreakModeWordWrap];

    CGRect resizedReviewBubbleFrame = reviewComment.frame;
    resizedReviewBubbleFrame.size.height = expectedReviewLabelSize.height + (USER_COMMENT_PADDING * 2);
    reviewComment.frame = resizedReviewBubbleFrame;
    
    CGRect resizedReviewLabelFrame = reviewComment.commentLabel.frame;
    resizedReviewLabelFrame.size.height = expectedReviewLabelSize.height;
    reviewComment.commentLabel.frame = resizedReviewLabelFrame;
    reviewComment.commentLabel.numberOfLines = 0;
    [reviewComment.commentLabel sizeToFit];
    yOffset += reviewComment.frame.size.height + USER_COMMENT_MARGIN;
    [reviewComment.profilePhoto setImageWithURL:[NSURL URLWithString:feedItem.checkin.user.remoteProfilePhotoUrl]];
    [cell addSubview:reviewComment];
    
    NSLog(@"There are %d comments for this checkin", [feedItem.comments count]);
    for (Comment *comment in feedItem.comments) {
        NSLog(@"Comment #%d: %@", commentNumber, comment.comment);
        UserComment *userComment = [[UserComment alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
        userComment.tag = 999;
        userComment.commentLabel.text = comment.comment;
        // Find the height required given the text, width, and font size
        CGSize expectedLabelSize = [userComment.commentLabel.text sizeWithFont:userCommentFont
                                                        constrainedToSize:userComment.commentLabel.frame.size
                                                            lineBreakMode:UILineBreakModeWordWrap];
        
        // Ok lets expand the bubble view if needed
        CGRect resizedBubbleFrame = userComment.frame;
        resizedBubbleFrame.size.height = expectedLabelSize.height + (USER_COMMENT_PADDING * 2);
        userComment.frame = resizedBubbleFrame;
        
        // Ok lets adjust the label size
        CGRect resizedLabelFrame = userComment.commentLabel.frame;
        resizedLabelFrame.size.height = expectedLabelSize.height;
        userComment.commentLabel.frame = resizedLabelFrame;
        userComment.commentLabel.numberOfLines = 0;
        [userComment.commentLabel sizeToFit];
        
        // Update the new y offset
        yOffset += userComment.frame.size.height + USER_COMMENT_MARGIN;
        
        [userComment.profilePhoto setImageWithURL:[NSURL URLWithString:comment.user.remoteProfilePhotoUrl]];
        [cell addSubview:userComment];
    }
    
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.postcardPhoto setImageWithURL:[NSURL URLWithString:feedItem.checkin.firstPhoto.url] placeholderImage:self.placeHolderImage];
    [self setStars:[feedItem.checkin.userRating intValue] withCell:cell];
        
    //cell.profilePhoto.image = [newImage thumbnailImage:[Utils sizeForDevice:33.0] transparentBorder:2 cornerRadius:30 interpolationQuality:kCGInterpolationHigh];
    //[cell.profilePhoto setImageWithURL:[NSURL URLWithString:feedItem.user.remoteProfilePhotoUrl]];
    NSURLRequest *profileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedItem.user.remoteProfilePhotoUrl]];
    [cell.profilePhoto setImageWithURLRequest:profileRequest placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"photo loaded");
        UIImage *circleAvatar = [image thumbnailImage:[Utils sizeForDevice:29.0] transparentBorder:0 cornerRadius:[Utils sizeForDevice:14.5] interpolationQuality:kCGInterpolationHigh];
        [cell.profilePhoto setImage:circleAvatar];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"failure");
    } ];
    
    UIColor *pinkColor = RGBCOLOR(242, 95, 114);
    CALayer *backdropLayer = cell.profilePhotoBackdrop.layer;
    [backdropLayer setCornerRadius:16];
    [backdropLayer setBorderWidth:1];
    [backdropLayer setBorderColor:[pinkColor CGColor]];
    [backdropLayer setMasksToBounds:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Comment is %@", feedItem.checkin.comment);
    
    int totalHeight = INITIAL_BUBBLE_Y_OFFSET;
    
    // Set the review bubble
    BubbleCommentView *reviewComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, 60.0)];
    reviewComment.commentLabel.text = feedItem.checkin.review;
    CGSize expectedReviewLabelSize = [reviewComment.commentLabel.text sizeWithFont:userCommentFont
                                                                 constrainedToSize:reviewComment.commentLabel.frame.size
                                                                     lineBreakMode:UILineBreakModeWordWrap];
    
    
    totalHeight += expectedReviewLabelSize.height + (USER_COMMENT_PADDING * 2) + USER_COMMENT_MARGIN;
    
    for (Comment *comment in feedItem.comments) {
        
        BubbleCommentView *userComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, 60.0)];
        userComment.commentLabel.text = comment.comment;
        // Find the height required given the text, width, and font size
        CGSize expectedLabelSize = [userComment.commentLabel.text sizeWithFont:userCommentFont
                                                             constrainedToSize:userComment.commentLabel.frame.size
                                                                 lineBreakMode:UILineBreakModeWordWrap];
        
        NSLog(@"Expected user comment height %f", expectedLabelSize.height);
        totalHeight += expectedLabelSize.height + (USER_COMMENT_PADDING * 2) + USER_COMMENT_MARGIN;
    }

    return totalHeight;    
}


- (void)fetchResults {
    [RestFeedItem loadFeed:^(NSArray *feedItems) 
                {
                    for (RestFeedItem *feedItem in feedItems) {
                        //NSLog(@"FindOrCreate FeedItem with RestFeedItem: %@", feedItem);
                        NSLog(@"creating feeditem for %d", feedItem.externalId);
                        NSLog(@"and checkin %@", feedItem.checkin);
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

- (IBAction)dismissModal:(id)sender {
    NSLog(@"in dismiss modal inside index controller");
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [feedItem like:^(RestFeedItem *restFeedItem) 
            {
                NSLog(@"saving favorite counts with %d", restFeedItem.favorites);
                feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
                //[self saveContext];
                //[self.tableView reloadData];
        
            }
            onError:^(NSString *error) 
            {
                [SVProgressHUD showErrorWithStatus:error duration:1.0];
            }];
}

- (IBAction)didPressComment:(id)sender event:(UIEvent *)event {
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Comment" sender:feedItem];
    
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

- (void)setStars:(int)rating withCell:(PostCardCell *)cell {
    cell.star1.selected = cell.star2.selected = cell.star3.selected = cell.star4.selected = cell.star5.selected = NO;
    switch (rating) {
        case 5:
           cell.star1.selected = cell.star2.selected = cell.star3.selected = cell.star4.selected = cell.star5.selected = YES;
            break;
        case 4:
            cell.star1.selected = cell.star2.selected = cell.star3.selected = cell.star4.selected = YES;
            break;
        case 3:
            cell.star1.selected = cell.star2.selected = cell.star3.selected = YES;
            break;
        case 2:
            cell.star1.selected = cell.star2.selected = YES;
            break;
        case 1: 
            cell.star1.selected = YES;
        default:
            break;
    }
}
@end
