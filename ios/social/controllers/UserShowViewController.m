
#import "UserShowViewController.h"
#import "Vkontakte.h"
#import "UIBarButtonItem+Borderless.h"
#import "RestUser.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
#import "Checkin+Rest.h"
#import "Photo.h"
#import "Place.h"
#import "Comment.h"
#import "PostCardCell.h"
#import "NSDate+Formatting.h"
#import "ReviewBubble.h"
#import "UserComment.h"
#import "PostCardImageView.h"
#import "User+Rest.h"
#import "PhotoNewViewController.h"
#import "PlaceShowViewController.h"
#import "FriendsIndexViewController.h"
#import "FollowersIndexViewController.h"
#import "Utils.h"
#import "CommentCreateViewController.h"
#import "WarningBannerView.h"
#import "UserSettingsController.h"
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


@interface UserShowViewController ()

@end

@implementation UserShowViewController
@synthesize managedObjectContext;
@synthesize user;
@synthesize placeHolderImage;
@synthesize star1, star2, star3, star4, star5;
@synthesize mutualFriends;

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

    self.navigationItem.hidesBackButton = YES;
    
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIImage *settingsButtonImage = [UIImage imageNamed:@"settings.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *settingsButtonItem = [UIBarButtonItem barItemWithImage:settingsButtonImage target:self action:@selector(didClickSettings:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, dismissButtonItem, nil]];
    if (self.user.isCurrentUser) {
        DLog(@"is current user");
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, settingsButtonItem, nil]];
    }
    
	// Do any additional setup after loading the view.
    [self.userFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%u", [self.user.followers count]]];
    self.userNameHeaderLabel.text = self.user.fullName;
    self.userLocationHeaderLabel.text = self.user.location;
    [self.checkinsButton setTitle:[NSString stringWithFormat:@"%u", [self.user.checkins count]] forState:UIControlStateNormal];
    [self.userProfilePhotoViewHeader setProfileImageForUser:self.user];
    
}


- (void)isFollowing {
    
}


- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriends];
    [self fetchResults];
    self.title = self.user.normalFullName;
    [RestClient sharedClient].delegate = self;
}

- (void)viewDidUnload
{
    [self setUserProfilePhotoViewHeader:nil];
    [self setUserNameHeaderLabel:nil];
    [self setUserLocationHeaderLabel:nil];
    [self setUserFollowingHeaderButton:nil];
    [self setUserMutualFollowingHeaderButton:nil];
    [self setCheckinsButton:nil];
    [self setFollowUnfollowButton:nil];
    [super viewDidUnload];
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
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentCreateViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
    } else if ([[segue identifier] isEqualToString:@"FollowersIndex"]) {
        FollowersIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
        //vc.followers = self.user.followers;
    } else if ([[segue identifier] isEqualToString:@"MutalFriendsIndex"]) {
        FriendsIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
        vc.mutualFriends = self.mutualFriends;
    } else if ([[segue identifier] isEqualToString:@"UserSettings"]) {
        UserSettingsController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.user = self.user;
    }
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
        [cell.postcardPhoto.activityIndicator startAnimating];
    }
    
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.profilePhotoBackdrop.hidden = YES;
        [cell.favoriteButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.postcardPhoto.frame.origin.y, cell.favoriteButton.frame.size.width, cell.favoriteButton.frame.size.height)];
        [cell.addCommentButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.favoriteButton.frame.origin.y + 42.0, cell.addCommentButton.frame.size.width, cell.addCommentButton.frame.size.height)];
        [cell.shareButton setFrame:CGRectMake(cell.addCommentButton.frame.origin.x, cell.addCommentButton.frame.origin.y + 42.0, cell.shareButton.frame.size.width, cell.shareButton.frame.size.height)];
    } else {
        cell.profilePhotoBackdrop.hidden = NO;
        [cell.favoriteButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.profilePhotoBackdrop.frame.origin.y + 42.0, cell.favoriteButton.frame.size.width, cell.favoriteButton.frame.size.height)];
        [cell.addCommentButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.favoriteButton.frame.origin.y + 42.0, cell.addCommentButton.frame.size.width, cell.addCommentButton.frame.size.height)];
        [cell.shareButton setFrame:CGRectMake(cell.addCommentButton.frame.origin.x, cell.addCommentButton.frame.origin.y + 42.0, cell.shareButton.frame.size.width, cell.shareButton.frame.size.height)];
    }
        
    
    
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    cell.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[feedItem.checkin.place.typeId integerValue]];

    
    NSArray *comments = [feedItem.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    if ([comments count] == 0) {
        cell.commentsView.hidden = YES;
    }
    if ([comments count] > 0) {
        cell.commentsView.hidden = NO;
        cell.seeMoreCommentsButton.hidden = YES;
        cell.comment2Label.hidden = YES;
        cell.comment2ProfilePhoto.hidden = YES;
        Comment *comment1 = [comments objectAtIndex:[comments count] - 1];
        cell.comment1Label.text = comment1.comment;
        [cell.comment1ProfilePhoto setProfileImageForUser:comment1.user];
        [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.comment1Label.frame.origin.y + cell.comment1Label.frame.size.height) + 5.0)];
    }
    if ([comments count] > 1) {
        cell.comment2Label.hidden = NO;
        cell.comment2ProfilePhoto.hidden = NO;
        Comment *comment2 = [comments objectAtIndex:[comments count] - 2];
        cell.comment2Label.text = comment2.comment;
        [cell.comment2ProfilePhoto setProfileImageForUser:comment2.user];
        [cell.commentsView setFrame:CGRectMake(cell.commentsView.frame.origin.x, cell.commentsView.frame.origin.y, cell.commentsView.frame.size.width, (cell.comment2Label.frame.origin.y + cell.comment2Label.frame.size.height) + 5.0)];
    }
    if ([comments count] > 2) {
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

    
    
    
    
    
    if ([feedItem.meLiked boolValue]) {
        cell.favoriteButton.selected = YES;
    } else {
        cell.favoriteButton.selected = NO;
    }
    
    //favorite count
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateSelected];
    
    //comment count
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateNormal];
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateHighlighted];
    [cell.addCommentButton setTitle:[NSString stringWithFormat:@"%u", [feedItem.comments count]] forState:UIControlStateSelected];

    
    // Set postcard image
    [cell.postcardPhoto setPostcardPhotoWithURL:feedItem.checkin.firstPhoto.url];
    
    // Set profile image
    [cell.profilePhotoBackdrop setProfileImageWithUrl:feedItem.user.remoteProfilePhotoUrl];
    
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
    
    //    for (Comment *comment in feedItem.comments) {
    //
    //        BubbleCommentView *userComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, CGFLOAT_MAX)];
    //        userComment.commentLabel.text = comment.comment;
    //        [userComment setCommentText:comment.comment];
    //        totalHeight += userComment.frame.size.height;
    //    }
    
    return totalHeight;    

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissModal:(id)sender {
    [self.delegate didDismissProfile];
}

- (IBAction)didClickSettings:(id)sender {
    [self performSegueWithIdentifier:@"UserSettings" sender:self];
}

-(void) fetchResults {
    [RestFeedItem loadUserFeed:self.user.externalId onLoad:^(NSSet *feedItems) {
        for (RestFeedItem *restFeedItem in feedItems) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
        }
    } onError:^(NSString *error) {
        DLog(@"Error loading user's feed: %@", error);
    } withPage:1];
}

- (void)fetchFriends {
    [RestUser loadFollowing:^(NSSet *users) {
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowingObject:_user];
        }
        NSMutableSet *followers = [NSMutableSet setWithSet:self.user.followers];
        NSMutableSet *following = [NSMutableSet setWithSet:self.user.following];
        [followers intersectSet:following];
        NSArray* result = [followers allObjects];
        [self.userMutualFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [result count]] forState:UIControlStateNormal];
        [self.userMutualFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [result count]] forState:UIControlStateHighlighted];
        [self.userFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [following count]] forState:UIControlStateNormal];
        [self.userFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [following count]] forState:UIControlStateHighlighted];
    } onError:^(NSString *error) {
        DLog(@"Error loading following %@", error);
        //
    }];
    
    [RestUser loadFollowers:^(NSSet *users) {
        for (RestUser *restUser in users) {
            User *_user = [User userWithRestUser:restUser inManagedObjectContext:self.managedObjectContext];
            [self.user addFollowersObject:_user];
        }
        NSMutableSet *followers = [NSMutableSet setWithSet:self.user.followers];
        NSMutableSet *following = [NSMutableSet setWithSet:self.user.following];
        [followers intersectSet:following];
        NSArray *result = [followers allObjects];
        self.mutualFriends = result;
        [self.userMutualFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [result count]] forState:UIControlStateNormal];
        [self.userMutualFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [result count]] forState:UIControlStateHighlighted];
        [self.userFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [following count]] forState:UIControlStateNormal];
        [self.userFollowingHeaderButton setTitle:[NSString stringWithFormat:@"%d", [following count]] forState:UIControlStateHighlighted];

    } onError:^(NSString *error) {
        DLog(@"Error loading followers %@", error);
    }];
    
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

- (IBAction)didPressComment:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"Comment" sender:feedItem];
    
}

- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    if ([feedItem.meLiked boolValue]) {
        [feedItem unlike:^(RestFeedItem *restFeedItem) {
            feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
            
            DLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
        } onError:^(NSString *error) {
            DLog(@"Error unliking feed item %@", error);
            [SVProgressHUD showErrorWithStatus:error duration:1.0];
        }];
    } else {
        [feedItem like:^(RestFeedItem *restFeedItem)
         {
             DLog(@"saving favorite counts with %d", restFeedItem.favorites);
             feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
             feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
         }
               onError:^(NSString *error)
         {
             [SVProgressHUD showErrorWithStatus:error duration:1.0];
         }];
    }

}

#pragma mark - NetworkReachabilityDelegate
- (void)networkReachabilityDidChange:(BOOL)connected {
    DLog(@"NETWORK AVAIL CHANGED");
    [self.tableView reloadData];
    [self fetchResults];
}

@end
