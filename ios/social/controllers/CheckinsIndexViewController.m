
#import "CheckinsIndexViewController.h"
#import "PostCardCell.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import "UIBarButtonItem+Borderless.h"
#import "PlaceShowViewController.h"
#import "CommentCreateViewController.h"
#import "RestCheckin.h"
#import "RestPlace.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "Comment.h"
#import "Photo+Rest.h"
#import "Notification+Rest.h"
#import "UIImageView+AFNetworking.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
#import "BubbleCommentView.h"
#import "UserComment.h"
#import "ReviewBubble.h"
#import "NSDate+Formatting.h"
#import "UserShowViewController.h"
#import "BaseView.h"
#import "WarningBannerView.h"
#import "RestNotification.h"
#import "NotificationIndexViewController.h"
#define USER_COMMENT_MARGIN 0.0f
#define USER_COMMENT_WIDTH 251.0f
#define USER_COMMENT_PADDING 10.0f

#define POSTCARD_HEIGHT 250.0f
#define POSTCARD_MARGIN 13.0f

#define INITIAL_BUBBLE_Y_OFFSET 264.0f
#define BUBBLE_VIEW_X_OFFSET 60.0f
#define BUBBLE_VIEW_WIDTH 245.0f

#define MINIMUM_REVIEW_VIEW_HEIGHT 37.0f
#define MAXIMUM_REVIEW_VIEW_HEIGHT 70.0f
#define MAXIMUM_REVIEW_LABEL_WIDTH 230.0f

@interface CheckinsIndexViewController ()

@end

@implementation CheckinsIndexViewController

@synthesize managedObjectContext;
@synthesize placeHolderImage;
@synthesize star1, star2, star3, star4, star5;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) 
    {
        self.star1 = [UIImage imageNamed:@"stars1"];
        self.star2 = [UIImage imageNamed:@"stars2"];
        self.star3 = [UIImage imageNamed:@"stars3"];
        self.star4 = [UIImage imageNamed:@"stars4"];
        self.star5 = [UIImage imageNamed:@"stars5"];
        self.placeHolderImage = [UIImage imageNamed:@"placeholder.png"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation-logo.png"]]];
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RestClient sharedClient].delegate = self;
    [self fetchResults];
    [self fetchNotifications];
    
    if (self.currentUser.numberOfUnreadNotifications > 0) {
        [self setupNotificationBarButton];
    } else {
        [self setupProfileBarButton];
    }
    
    [Flurry logEvent:@"SCREEN_FEED"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    DLog(@"viewDidUnload");
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
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
    } else if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UserShowViewController *vc = (UserShowViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        User *user = (User *)sender;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.user = user;        
    } else if ([[segue identifier] isEqualToString:@"Notifications"]) {
        NotificationIndexViewController *vc = (NotificationIndexViewController *)[segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.currentUser = self.currentUser;
    }

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == 0) && ([RestClient sharedClient].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) ) {
        return 30;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ((section == 0) && ([RestClient sharedClient].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)) {
        UIView *view = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_CONNECTION_FOR_FEED", @"Unable to refresh content because no network")];
        return view;
    }
    return nil;
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
                [subview removeFromSuperview];
            }
        }
        [cell.postcardPhoto.activityIndicator startAnimating];
    }
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    cell.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[feedItem.checkin.place.typeId integerValue]];
    //comments v2
    int commentNumber = 1;
    int yOffset = INITIAL_BUBBLE_Y_OFFSET;
    
    // Create the comment bubble left
    ReviewBubble *reviewComment = nil;
    // Now create all the comment bubbles left by other users
    NSArray *comments = [feedItem.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    int numComments = 1;
    int totalComments = [comments count];
    for (Comment *comment in comments) {
        if(!reviewComment) {
            reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
            [reviewComment setReviewText:comment.comment];
            yOffset += reviewComment.frame.size.height + USER_COMMENT_MARGIN;
            [reviewComment setProfilePhotoWithUrl:comment.user.remoteProfilePhotoUrl];
            if (totalComments == numComments)
                reviewComment.isLastComment = YES;
            [cell addSubview:reviewComment];
            numComments++;
            continue;
        }
        
        UserComment *userComment = [[UserComment alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
        [userComment setCommentText:comment.comment];
        
        // Update the new y offset
        yOffset += userComment.frame.size.height + USER_COMMENT_MARGIN;
        
        // Set the profile photo
        [userComment setProfilePhotoWithUrl:comment.user.remoteProfilePhotoUrl];
        if (totalComments == numComments)
            userComment.isLastComment = YES;
        numComments++;
        [cell addSubview:userComment];
    }
    
    
    
    if (feedItem.checkin.review.length > 0) {
        cell.reviewTextLabel.hidden = NO;
        cell.reviewTextLabel.text = [feedItem.checkin.review truncatedQuote];
        CGSize expectedReviewLabelSize = [cell.reviewTextLabel.text sizeWithFont:cell.reviewTextLabel.font
                                                            constrainedToSize:CGSizeMake(MAXIMUM_REVIEW_LABEL_WIDTH, MAXIMUM_REVIEW_VIEW_HEIGHT)
                                                                lineBreakMode:UILineBreakModeWordWrap];
        
        
        float expectedFrameSize =  expectedReviewLabelSize.height + MINIMUM_REVIEW_VIEW_HEIGHT;
        float expectedLabelSize = expectedReviewLabelSize.height; 
        [cell.reviewView setFrame:CGRectMake(cell.reviewView.frame.origin.x, (cell.postcardPhoto.frame.size.height + cell.postcardPhoto.frame.origin.y) - expectedFrameSize, cell.reviewView.frame.size.width, expectedFrameSize)];
        [cell.placeTypeImageView setFrame:CGRectMake(cell.placeTypeImageView.frame.origin.x, cell.reviewView.frame.origin.y + 5, cell.placeTypeImageView.frame.size.width, cell.placeTypeImageView.frame.size.height)];
        [cell.starsImageView setFrame:CGRectMake(cell.starsImageView.frame.origin.x, cell.reviewView.frame.origin.y + 5, cell.starsImageView.frame.size.width, cell.starsImageView.frame.size.height)];

        [cell.reviewTextLabel setFrame:CGRectMake(cell.reviewTextLabel.frame.origin.x, MINIMUM_REVIEW_VIEW_HEIGHT - 5, MAXIMUM_REVIEW_LABEL_WIDTH, expectedLabelSize)];
        cell.reviewTextLabel.numberOfLines = 0;
        [cell.reviewTextLabel sizeToFit];
        //cell.reviewView.backgroundColor = [UIColor redColor];
        
    } else {
        cell.reviewTextLabel.hidden = YES;
        [cell.reviewView setFrame:CGRectMake(cell.reviewView.frame.origin.x, (cell.postcardPhoto.frame.size.height + cell.postcardPhoto.frame.origin.y) - MINIMUM_REVIEW_VIEW_HEIGHT, cell.reviewView.frame.size.width, MINIMUM_REVIEW_VIEW_HEIGHT)];
        [cell.placeTypeImageView setFrame:CGRectMake(cell.placeTypeImageView.frame.origin.x, cell.reviewView.frame.origin.y + 5, cell.placeTypeImageView.frame.size.width, cell.placeTypeImageView.frame.size.height)];
        [cell.starsImageView setFrame:CGRectMake(cell.starsImageView.frame.origin.x, cell.reviewView.frame.origin.y + 5, cell.starsImageView.frame.size.width, cell.starsImageView.frame.size.height)];

        //cell.reviewView.backgroundColor = [UIColor blueColor];
    }
    //cell.reviewTextLabel.backgroundColor = [UIColor greenColor];
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    
    
    
    
    
    if ([feedItem.meLiked boolValue]) {
        cell.favoriteButton.selected = YES;
    } else {
        cell.favoriteButton.selected = NO;
    }
    DLog(@"likes are %@", [feedItem.favorites stringValue]);
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateSelected];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    // Set postcard image
    [cell.postcardPhoto setPostcardPhotoWithURL:[feedItem.checkin firstPhoto].url];
        
    // Set profile image
    [cell.profilePhotoBackdrop setProfileImageWithUrl:feedItem.user.remoteProfilePhotoUrl];
    cell.profilePhotoBackdrop.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressProfilePhoto:)];
    [cell.profilePhotoBackdrop addGestureRecognizer:tap];
    cell.profilePhotoBackdrop.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    int totalHeight = INITIAL_BUBBLE_Y_OFFSET;
    for (Comment *comment in feedItem.comments) {
        
        BubbleCommentView *userComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, CGFLOAT_MAX)];
        userComment.commentLabel.text = comment.comment;
        [userComment setCommentText:comment.comment];
        totalHeight += userComment.frame.size.height;
    }

    return totalHeight;    
}

- (void)fetchResults {
    if([[self.fetchedResultsController fetchedObjects] count] == 0)
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"LOADING", @"Show loading if no feed items are present yet")];
    
    [RestFeedItem loadFeed:^(NSArray *feedItems)
                {
                    for (RestFeedItem *feedItem in feedItems) {
                        DLog(@"creating feeditem for %d", feedItem.externalId);
                        [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:self.managedObjectContext];
                    }
                    [self saveContext];
                    [self.tableView reloadData];
                }
                onError:^(NSString *error) {
                    DLog(@"Problem loading feed %@", error);
                    [SVProgressHUD showErrorWithStatus:error duration:1.0];
                }
                withPage:1];

}

- (void)fetchNotifications {
    [RestNotification load:^(NSSet *notificationItems) {
        for (RestNotification *restNotification in notificationItems) {
            DLog(@"%@", restNotification);
            Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
            [self.currentUser addNotificationsObject:notification];
        }
            
        [self saveContext];
        if (self.currentUser.numberOfUnreadNotifications > 0) {
            [self setupNotificationBarButton];
        }
        DLog(@"user has %d total notfications", [self.currentUser.notifications count]);
        DLog(@"User has %d unread notifications", self.currentUser.numberOfUnreadNotifications);
    } onError:^(NSString *error) {
        
    }];
}

- (void)setupNotificationBarButton {
    UIImage *notificationsImage = [UIImage imageNamed:@"notifications.png"];
    UIBarButtonItem *notificationButton = [UIBarButtonItem barItemWithImage:notificationsImage target:self action:@selector(didSelectNotifications:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, notificationButton, nil];
}

- (void)setupProfileBarButton {
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];
}
     
- (IBAction)didSelectSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserShow" sender:self.currentUser];
}


- (IBAction)didCheckIn:(id)sender {
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (IBAction)didSelectNotifications:(id)sender {
    [self performSegueWithIdentifier:@"Notifications" sender:self];
}


- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"did like, send to delegate");
    
    DLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    if ([feedItem.meLiked boolValue]) {
        //Update the UI now
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] - 1)];
        feedItem.meLiked = [NSNumber numberWithBool:NO];
        
        [feedItem unlike:^(RestFeedItem *restFeedItem) {
            feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
            
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
        } onError:^(NSString *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            feedItem.meLiked = [NSNumber numberWithBool:YES];
            feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error duration:1.0];
        }];
    } else {
        //Update the UI so the responsiveness seems fast
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
        feedItem.meLiked = [NSNumber numberWithBool:YES];

        [feedItem like:^(RestFeedItem *restFeedItem)
         {
             DLog(@"saving favorite counts with %d", restFeedItem.favorites);
             feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
             feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
         }
               onError:^(NSString *error)
         {
             // Request failed, we need to back out the temporary chagnes we made
             feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] - 1)];
             feedItem.meLiked = [NSNumber numberWithBool:NO];
             [SVProgressHUD showErrorWithStatus:error duration:1.0];
         }];
    }

    
}

- (IBAction)didPressComment:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Comment" sender:feedItem];
    
}


- (IBAction)didPressProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger row = tap.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    DLog(@"row is %d", indexPath.row);
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"feed item from didPress is %@", feedItem.checkin.user.normalFullName);
    [self performSegueWithIdentifier:@"UserShow" sender:feedItem.checkin.user];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

- (UIImage *)setStars:(int)rating {
    if (rating == 1) {
        
        return self.star1;
    } else if (rating == 2) {
        return self.star2;
    } else if (rating == 3) {
        return self.star3;
    } else if (rating == 4) {
        return self.star4;
    } else {
        return self.star5;
    }
}


# pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - NetworkReachabilityDelegate
- (void)networkReachabilityDidChange:(BOOL)connected {
    DLog(@"NETWORK AVAIL CHANGED");
    [self.tableView reloadData];
    [self fetchResults];
}


@end
