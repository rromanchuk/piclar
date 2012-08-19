
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

#define USER_COMMENT_MARGIN 0.0f
#define USER_COMMENT_WIDTH 251.0f
#define USER_COMMENT_PADDING 10.0f

#define POSTCARD_HEIGHT 250.0f
#define POSTCARD_MARGIN 13.0f

#define INITIAL_BUBBLE_Y_OFFSET 264.0f
#define BUBBLE_VIEW_X_OFFSET 60.0f
#define BUBBLE_VIEW_WIDTH 245.0f

@interface UserShowViewController ()

@end

@implementation UserShowViewController
@synthesize dismissButton;
@synthesize logoutButton;
@synthesize managedObjectContext;
@synthesize user;
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
    self.navigationItem.hidesBackButton = YES;
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIImage *logoutButtonImage = [UIImage imageNamed:@"logout-icon.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *logoutButtonItem = [UIBarButtonItem barItemWithImage:logoutButtonImage target:self action:@selector(didLogout:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 10;
    self.dismissButton = dismissButtonItem;
    self.logoutButton = logoutButtonItem;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, self.dismissButton, nil]];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:fixed, self.logoutButton, nil]];
	// Do any additional setup after loading the view.
    
    [self.userFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%u", [self.user.followers count]]];
    self.userNameHeaderLabel.text = self.user.fullName;
    self.userLocationHeaderLabel.text = self.user.location;
    NSURLRequest *userHeaderProfileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.user.remoteProfilePhotoUrl]];
    [self.userProfilePhotoViewHeader.profileImageView setImageWithURLRequest:userHeaderProfileRequest
                                                       placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                    self.userProfilePhotoViewHeader.profileImage = image;
                                                                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                    NSLog(@"Failure loading review profile photo with request %@ and errer %@", request, error);
                                                                }];

}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"user = %@", self.user];

    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriends];
    [self fetchResults];
    self.title = NSLocalizedString(@"PROFILE", "User's profile page title");
    [self setupFetchedResultsController];
}
- (void)viewDidUnload
{
    [self setDismissButton:nil];
    [self setUserProfilePhotoViewHeader:nil];
    [self setUserNameHeaderLabel:nil];
    [self setUserLocationHeaderLabel:nil];
    [self setUserFollowingHeaderButton:nil];
    [self setUserMutualFollowingHeaderButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    if (indexPath.row == 0) {
        cell.profilePhotoBackdrop.hidden = YES;
        [cell.favoriteButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.postcardPhoto.frame.origin.y, cell.favoriteButton.frame.size.width, cell.favoriteButton.frame.size.height)];
        [cell.addCommentButton setFrame:CGRectMake(cell.favoriteButton.frame.origin.x, cell.favoriteButton.frame.origin.y + 42.0, cell.addCommentButton.frame.size.width, cell.addCommentButton.frame.size.height)];
        [cell.shareButton setFrame:CGRectMake(cell.addCommentButton.frame.origin.x, cell.addCommentButton.frame.origin.y + 42.0, cell.shareButton.frame.size.width, cell.shareButton.frame.size.height)];
    }
        
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    NSLog(@"This place has a user rating of %@", feedItem.checkin.userRating);
    
    //comments v2
    int commentNumber = 1;
    int yOffset = cell.postcardPhoto.frame.origin.y + cell.postcardPhoto.frame.size.height;
    
    // Create the comment bubble left
    ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(cell.postcardPhoto.frame.origin.x, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
    reviewComment.tag = 999;
    reviewComment.commentLabel.text = feedItem.checkin.review;
    CGSize expectedReviewLabelSize = [reviewComment.commentLabel.text sizeWithFont:reviewComment.commentLabel.font
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
    
    // Set the profile photo
    NSLog(@"User profile photo is %@", feedItem.checkin.user.remoteProfilePhotoUrl);
    NSLog(@"User is %@", feedItem.checkin.user);
    [reviewComment.profilePhoto setProfileImageWithUrl:feedItem.checkin.user.remoteProfilePhotoUrl];
    
    
    [cell addSubview:reviewComment];
    
    // Now create all the comment bubbles left by other users
    NSLog(@"There are %d comments for this checkin", [feedItem.comments count]);
    for (Comment *comment in feedItem.comments) {
        NSLog(@"Comment #%d: %@", commentNumber, comment.comment);
        UserComment *userComment = [[UserComment alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
        userComment.tag = 999;
        userComment.commentLabel.text = comment.comment;
        // Find the height required given the text, width, and font size
        CGSize expectedLabelSize = [userComment.commentLabel.text sizeWithFont:userComment.commentLabel.font
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
        
        // Set the profile photo
        [userComment.profilePhoto setProfileImageWithUrl:comment.user.remoteProfilePhotoUrl];
        [cell addSubview:userComment];
    }
    
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    
    // Set postcard image
    [cell setPostcardPhotoWithURL:feedItem.checkin.firstPhoto.url];
    
    // Set profile image
    [cell.profilePhotoBackdrop setProfileImageWithUrl:feedItem.user.remoteProfilePhotoUrl];
    
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
    CGSize expectedReviewLabelSize = [reviewComment.commentLabel.text sizeWithFont:reviewComment.commentLabel.font
                                                                 constrainedToSize:reviewComment.commentLabel.frame.size
                                                                     lineBreakMode:UILineBreakModeWordWrap];
    
    
    totalHeight += expectedReviewLabelSize.height + (USER_COMMENT_PADDING * 2) + USER_COMMENT_MARGIN;
    
    for (Comment *comment in feedItem.comments) {
        
        BubbleCommentView *userComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, 60.0)];
        userComment.commentLabel.text = comment.comment;
        // Find the height required given the text, width, and font size
        CGSize expectedLabelSize = [userComment.commentLabel.text sizeWithFont:userComment.commentLabel.font
                                                             constrainedToSize:userComment.commentLabel.frame.size
                                                                 lineBreakMode:UILineBreakModeWordWrap];
        
        NSLog(@"Expected user comment height %f", expectedLabelSize.height);
        totalHeight += expectedLabelSize.height + (USER_COMMENT_PADDING * 2) + USER_COMMENT_MARGIN;
    }
    
    return totalHeight;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissModal:(id)sender {
    NSLog(@"DISMISSING MODAL");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dismissModal"
     object:self];
}

- (IBAction)didLogout:(id)sender {
    NSLog(@"USER CLICKED LOGOUT");
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"DidLogoutNotification" 
     object:self];
}

-(void) fetchResults {
    [RestFeedItem loadUserFeed:self.user.externalId onLoad:^(NSSet *feedItems) {
        for (RestFeedItem *restFeedItem in feedItems) {
            [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
        }
    } onError:^(NSString *error) {
        NSLog(@"Error loading user's feed: %@", error);
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
        [self.userMutualFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%d", [result count]]];
        [self.userFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%d", [following count]]];
    } onError:^(NSString *error) {
        NSLog(@"Error loading following %@", error);
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
        NSArray* result = [followers allObjects];
        [self.userMutualFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%d", [result count]]];
        [self.userFollowingHeaderButton.titleLabel setText:[NSString stringWithFormat:@"%d", [following count]]];


    } onError:^(NSString *error) {
        NSLog(@"Error loading followers %@", error);
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

@end
