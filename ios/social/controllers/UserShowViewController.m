
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

#define SCROLL_VIEW_HEIGHT 75.0f
#define SCROLL_VIEW_MARGIN 10.0f

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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    self.navigationItem.rightBarButtonItem = self.logoutButton;
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
    }
    // Add scrollview
    UIScrollView *placePhotosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5.0, cell.postcardPhoto.frame.origin.y + SCROLL_VIEW_MARGIN, 320.0, SCROLL_VIEW_HEIGHT)];
    placePhotosScrollView.tag = 999;
    int offsetX = 10;
    for (Photo *photo in feedItem.checkin.place.photos) {
        PostCardImageView *photoView = [[PostCardImageView alloc] initWithFrame:CGRectMake(offsetX, 0.0, 68.0, 67.0)];
        [photoView setImageWithURL:[NSURL URLWithString:photo.url]];
        photoView.backgroundColor = [UIColor blackColor];
        [placePhotosScrollView addSubview:photoView];
        offsetX += 10 + photoView.frame.size.width;
    }
    
    [placePhotosScrollView setContentSize:CGSizeMake(offsetX, 68)];
    [cell addSubview:placePhotosScrollView];
    
    cell.timeAgoInWords.text = [feedItem.checkin.createdAt distanceOfTimeInWords];
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    NSLog(@"This place has a user rating of %@", feedItem.checkin.userRating);
    //comments v2
    int commentNumber = 1;
    int yOffset = INITIAL_BUBBLE_Y_OFFSET;
    
    // Create the comment bubble left
    ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
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
    NSURLRequest *reviewCommentRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedItem.checkin.user.remoteProfilePhotoUrl]];
    [reviewComment.profilePhoto.profileImageView setImageWithURLRequest:reviewCommentRequest
                                                       placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                    reviewComment.profilePhoto.profileImage = image;
                                                                }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                    NSLog(@"Failure loading review profile photo with request %@ and errer %@", request, error);
                                                                }];
    
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
        NSURLRequest *userCommentRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:comment.user.remoteProfilePhotoUrl]];
        [userComment.profilePhoto.profileImageView setImageWithURLRequest:userCommentRequest
                                                         placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                      userComment.profilePhoto.profileImage = image;
                                                                  }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                      NSLog(@"failure");
                                                                  }];
        
        [cell addSubview:userComment];
    }
    
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    
    // Set postcard image
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedItem.checkin.firstPhoto.url]];
    [cell.postcardPhoto setImageWithURLRequest:postcardRequest
                              placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [cell.activityIndicator stopAnimating];
                                       }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"failure");
                                       }];
    
    
    
    NSURLRequest *profileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedItem.user.remoteProfilePhotoUrl]];
    [cell.profilePhotoBackdrop.profileImageView setImageWithURLRequest:profileRequest
                                                      placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]
                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                   NSLog(@"photo loaded");
                                                                   cell.profilePhotoBackdrop.profileImage = image;
                                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                   NSLog(@"failure");
                                                               } ];
    
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
    
    return totalHeight + SCROLL_VIEW_HEIGHT + (SCROLL_VIEW_MARGIN * 2);
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
        [self.user addFollowing:users];
    } onError:^(NSString *error) {
        //
    }];
    
    [RestUser loadFollowers:^(NSSet *users) {
        [self.user addFollowers:users];
    } onError:^(NSString *error) {
        NSLog(@"");
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
