
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
#import "NSDate+Formatting.h"
#import "UserShowViewController.h"
#import "WarningBannerView.h"
#import "RestNotification.h"
#import "NotificationIndexViewController.h"
#import "AppDelegate.h"

#define INITIAL_BUBBLE_Y_OFFSET 264.0f

#define MINIMUM_REVIEW_VIEW_HEIGHT 37.0f
#define MAXIMUM_REVIEW_VIEW_HEIGHT 70.0f
#define MAXIMUM_REVIEW_LABEL_WIDTH 230.0f

@interface CheckinsIndexViewController () {
    //UITapGestureRecognizer *tap;
    BOOL isFullScreen;
    CGRect prevFrame;
    UIView *fullscreenBackground;
    PostCardImageView *fullscreenImage;
    BOOL noResultsModalShowing;
}

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    DLog(@"viewDidUnload");
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
        [self dismissNoResultsView];
    } else {
        [self dismissNoResultsView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [RestClient sharedClient].delegate = self;
    
    
    [self fetchResults];
    [self fetchNotifications];
       
    
    if (self.currentUser.numberOfUnreadNotifications > 0) {
    //if (YES) {
        [self setupNotificationBarButton];
    } else {
        [self setupProfileBarButton];
    }
    
    [Flurry logEvent:@"SCREEN_FEED"];
    
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
        noResultsModalShowing = NO;
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

- (void)userClickedCheckin {
    DLog(@"in delegate method of no results");
    [self.navigationController popViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"Checkin" sender:self];
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
        cell.postcardPhoto.userInteractionEnabled = NO;
        [cell.postcardPhoto.activityIndicator startAnimating];
    }

    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray *comments = [feedItem.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressProfilePhoto:)];
    UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
    
    UITapGestureRecognizer *tapComment1Profile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressCommentProfilePhoto:)];
    UITapGestureRecognizer *tapComment2Profile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressCommentProfilePhoto:)];
    
    [cell.profilePhotoBackdrop addGestureRecognizer:tapProfile];
    [cell.postcardPhoto addGestureRecognizer:tapPostCardPhoto];
    [cell.comment1ProfilePhoto addGestureRecognizer:tapComment1Profile];
    [cell.comment2ProfilePhoto addGestureRecognizer:tapComment2Profile];
    
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    cell.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[feedItem.checkin.place.typeId integerValue]];
    
#warning clean this up
    int numComments = [comments count];
    if (numComments == 0) {
        cell.commentsView.hidden = YES;
    }
    else if (numComments == 1) {
        cell.commentsView.hidden = NO;
        cell.seeMoreCommentsButton.hidden = YES;
        cell.comment2Label.hidden = YES;
        cell.comment2ProfilePhoto.hidden = YES;
        cell.commentSeparator.hidden = YES;
        Comment *comment1 = [comments lastObject];
        cell.comment1Label.text = comment1.comment;
        [cell.comment1ProfilePhoto setProfileImageForUser:comment1.user];
        cell.comment1ProfilePhoto.tag = [comment1.user.externalId integerValue];
        [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.comment1Label.frame.origin.y + cell.comment1Label.frame.size.height) + 5.0)];
    }
    else if (numComments >= 2) {
        cell.seeMoreCommentsButton.hidden = YES;
        cell.commentsView.hidden = NO;
        cell.comment2Label.hidden = NO;
        cell.comment2ProfilePhoto.hidden = NO;
        cell.commentSeparator.hidden = NO;
        
        Comment *comment1 = [comments objectAtIndex:0];
        cell.comment1Label.text = comment1.comment;
        [cell.comment1ProfilePhoto setProfileImageForUser:comment1.user];
        cell.comment1ProfilePhoto.tag = [comment1.user.externalId integerValue];
        [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.comment1Label.frame.origin.y + cell.comment1Label.frame.size.height) + 5.0)];
        
        
        Comment *comment2 = [comments objectAtIndex:1];
        cell.comment2Label.text = comment2.comment;
        cell.comment2ProfilePhoto.tag = [comment2.user.externalId integerValue];
        [cell.comment2ProfilePhoto setProfileImageForUser:comment2.user];
        [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.comment2Label.frame.origin.y + cell.comment2Label.frame.size.height) + 5.0)];
        
        if (numComments > 2) {
            cell.seeMoreCommentsButton.hidden = NO;
            NSString *seeMore;
            if ([comments count] > 4) {
                seeMore = [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"READ_ALL", @"Read all"), [comments count], NSLocalizedString(@"PLURAL_COMMENTS", @"five or more comments")];
            } else {
                seeMore = [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"READ_ALL", @"Read all"), [comments count], NSLocalizedString(@"PLURAL_COMMENTS_SECONDARY", @"two-four comments")];
            }
            
            [cell.seeMoreCommentsButton setTitle:seeMore forState:UIControlStateNormal];
            [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.seeMoreCommentsButton.frame.origin.y + cell.seeMoreCommentsButton.frame.size.height) + 5.0)];
        }

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
    
    
    
    
    
    
    if ([feedItem.meLiked boolValue]) {
        DLog(@"SELECTED YES");
        cell.favoriteButton.selected = YES;
    } else {
        cell.favoriteButton.selected = NO;
        DLog(@"SELECTED NO");

    }
    DLog(@"likes are %@", [feedItem.favorites stringValue]);
    
   
    
    
    
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateSelected];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateNormal];
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateHighlighted];
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateSelected];

    // Set postcard image
    [cell.postcardPhoto setPostcardPhotoWithURL:[feedItem.checkin firstPhoto].url];
        
    // Set profile image
    [cell.profilePhotoBackdrop setProfileImageWithUrl:feedItem.user.remoteProfilePhotoUrl];
    cell.profilePhotoBackdrop.userInteractionEnabled = YES;
    cell.profilePhotoBackdrop.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    int totalHeight = INITIAL_BUBBLE_Y_OFFSET;
    if ([feedItem.comments count] > 2) {
        totalHeight += 100;
    } else if ([feedItem.comments count] == 2 ){
        totalHeight += 68;
    } else if ([feedItem.comments count] == 1) {
        totalHeight += 38;
    } else {
        totalHeight += 0;
    }
    

    return totalHeight;    
}

- (void)fetchResults {
    if([[self.fetchedResultsController fetchedObjects] count] == 0)
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", @"Show loading if no feed items are present yet")];
    
    
    [RestFeedItem loadFeed:^(NSArray *feedItems) {
        
        for (RestFeedItem *feedItem in feedItems) {
            [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:self.managedObjectContext];
        }
        [SVProgressHUD dismiss];
        [self saveContext];
        [self.tableView reloadData];
        if ([[self.fetchedResultsController fetchedObjects] count] > 0) {
            [self dismissNoResultsView];
        }
     } onError:^(NSString *error) {
         DLog(@"Problem loading feed %@", error);
         [SVProgressHUD showErrorWithStatus:error];
       }
      withPage:1];
    
    
}

- (void)dismissNoResultsView {
    if (noResultsModalShowing) {
        noResultsModalShowing = NO;
        [self dismissModalViewControllerAnimated:YES];
    }    
}

- (void)displayNoResultsView {
    if (!noResultsModalShowing) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        NoResultscontrollerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NoResultsController"];
        vc.delegate = self;
        noResultsModalShowing = YES;
        [vc.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation-logo.png"]]];
        
        UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
        UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
        UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixed.width = 5;
        vc.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];
        
        
        UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
        UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
        vc.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
        
        [self.navigationController pushViewController:vc animated:NO];
    }
}


- (void)fetchNotifications {
          [RestNotification load:^(NSSet *notificationItems) {
            for (RestNotification *restNotification in notificationItems) {
                DLog(@"notification %@", restNotification);
                Notification *notification = [Notification notificatonWithRestNotification:restNotification inManagedObjectContext:self.managedObjectContext];
                DLog("notification feed item is %@", notification.feedItem);
                [self.currentUser addNotificationsObject:notification];
            }
            
            [self saveContext];
            if (self.currentUser.numberOfUnreadNotifications > 0) {
                [self setupNotificationBarButton];
            }
            DLog(@"user has %d total notfications", [self.currentUser.notifications count]);
            DLog(@"User has %d unread notifications", self.currentUser.numberOfUnreadNotifications);
        } onError:^(NSString *error) {
            DLog(@"Problem loading notifications %@", error);
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
    DLog(@"liking feedItem %@", feedItem.checkin.place.title);
    
    DLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    if ([feedItem.meLiked boolValue]) {
        //Update the UI now
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] - 1)];
        feedItem.meLiked = [NSNumber numberWithBool:NO];
        [self.tableView reloadData];
        [feedItem unlike:^(RestFeedItem *restFeedItem) {
            feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
            
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
        } onError:^(NSString *error) {
            DLog(@"Error unliking feed item %@", error);
            // Request failed, we need to back out the temporary chagnes we made
            feedItem.meLiked = [NSNumber numberWithBool:YES];
            feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        //Update the UI so the responsiveness seems fast
        feedItem.favorites = [NSNumber numberWithInteger:([feedItem.favorites integerValue] + 1)];
        feedItem.meLiked = [NSNumber numberWithBool:YES];
        [self.tableView reloadData];
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
             [SVProgressHUD showErrorWithStatus:error];
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

- (IBAction)didPressCommentProfilePhoto:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    NSUInteger externalId = tap.view.tag;
    User *user =  [User userWithExternalId:[NSNumber numberWithInteger:externalId] inManagedObjectContext:self.managedObjectContext];
    [self performSegueWithIdentifier:@"UserShow" sender:user];
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

- (IBAction)didTapPostCard:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    //PostCardImageView *original = (PostCardImageView *)tap.view;
    PostCardImageView *image = (PostCardImageView *)tap.view;
    
    //[image setOrigin:CGPointMake(original.frame.origin.x, original.frame.origin.y+90)];
    //window size is bigger, so to set an image frame visionary at same place, you need to set origin point lower
    
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   


    
    if (!isFullScreen) {
        
        DLog(@"x:%f y:%f", image.frame.origin.x, image.frame.origin.y);
        
        CGRect frame = [image.superview convertRect:image.frame toView:sharedAppDelegate.window];
        fullscreenImage = [[PostCardImageView alloc] initWithFrame:frame];
        DLog(@"x:%f y:%f", fullscreenImage.frame.origin.x, fullscreenImage.frame.origin.y);
        prevFrame = fullscreenImage.frame;
        fullscreenImage.image = [image.image copy];
        [fullscreenImage.activityIndicator stopAnimating];
        
        fullscreenBackground = [[UIView alloc] initWithFrame:sharedAppDelegate.window.frame];
        UITapGestureRecognizer *tapPostCardPhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPostCard:)];
        [fullscreenBackground addGestureRecognizer:tapPostCardPhoto];
        fullscreenBackground.backgroundColor = [UIColor clearColor];
        [fullscreenBackground addSubview:fullscreenImage];
        [sharedAppDelegate.window addSubview:fullscreenBackground];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [fullscreenImage setFrame:CGRectMake(0,
                                                        100,
                                                        320,
                                                        320)];
                             fullscreenBackground.backgroundColor = [UIColor blackColor];
                         }completion:^(BOOL finished){
                             isFullScreen = YES;
                         }];
        return;
    } else {
//        [image removeFromSuperview];
//        [self.view addSubview:image];
        [UIView animateWithDuration:0.5
                         animations:^{
                             [fullscreenImage setFrame:prevFrame];
                             fullscreenBackground.backgroundColor = [UIColor clearColor];
                         }completion:^(BOOL finished){
                             [fullscreenBackground removeFromSuperview];
                             isFullScreen = NO;
                         }];
        return;
    }
    
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog(@"did finish decelerating");
    NSArray *visibleCells = self.tableView.visibleCells;
    for (PostCardCell *cell in visibleCells) {
        cell.postcardPhoto.userInteractionEnabled = YES;
    }
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


- (void)mergeChanges:(NSNotification*)notification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
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
