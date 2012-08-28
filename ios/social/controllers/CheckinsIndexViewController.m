
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
#import "Photo+Rest.h"
#import "UIImageView+AFNetworking.h"
#import "RestFeedItem.h"
#import "FeedItem+Rest.h"
#import "BubbleCommentView.h"
#import "UserComment.h"
#import "ReviewBubble.h"
#import "NSDate+Formatting.h"
#import "UserShowViewController.h"
#import "BaseView.h"
#define USER_COMMENT_MARGIN 0.0f
#define USER_COMMENT_WIDTH 251.0f
#define USER_COMMENT_PADDING 10.0f

#define POSTCARD_HEIGHT 250.0f
#define POSTCARD_MARGIN 13.0f

#define INITIAL_BUBBLE_Y_OFFSET 264.0f
#define BUBBLE_VIEW_X_OFFSET 60.0f
#define BUBBLE_VIEW_WIDTH 245.0f
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissModal:)
                                                 name:@"dismissModal"
                                               object:nil];

    
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIImage *profileImage = [UIImage imageNamed:@"profile.png"];
    UIBarButtonItem *profileButton = [UIBarButtonItem barItemWithImage:profileImage target:self action:@selector(didSelectSettings:)];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, profileButton, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    
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
    [self fetchResults];
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
        NSLog(@"Segue with feedItem %@", feedItem);
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"Comment"]) {
        CommentNewViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = (FeedItem *) sender;
    } else if ([[segue identifier] isEqualToString:@"UserShow"]) {
        UserShowViewController *vc = (UserShowViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        if([sender respondsToSelector:@selector(externalId:)]) {
            vc.user = ((FeedItem *)sender).user;
        } else {
            vc.user = self.currentUser;
        }
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    cell.starsImageView.image = [self setStars:[feedItem.checkin.userRating intValue]];
    cell.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[feedItem.checkin.place.typeId integerValue]];
    NSLog(@"This place has a user rating of %@", feedItem.checkin.userRating);
    //comments v2
    int commentNumber = 1;
    int yOffset = INITIAL_BUBBLE_Y_OFFSET;
    
    // Create the comment bubble left
    ReviewBubble *reviewComment = nil;
    if (feedItem.checkin.review && [feedItem.checkin.review length] > 0) {
        reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
        [reviewComment setReviewText:feedItem.checkin.review];
        yOffset += reviewComment.frame.size.height + USER_COMMENT_MARGIN;
        
        // Set the profile photo
        NSLog(@"User profile photo is %@", feedItem.checkin.user.remoteProfilePhotoUrl);
        NSLog(@"User is %@", feedItem.checkin.user);
        [reviewComment setProfilePhotoWithUrl:feedItem.checkin.user.remoteProfilePhotoUrl];
        if([feedItem.comments count] == 0)
            reviewComment.isLastComment = YES;
        [cell addSubview:reviewComment];
    }
    
    
    // Now create all the comment bubbles left by other users
    NSLog(@"There are %d comments for this checkin", [feedItem.comments count]);
    NSArray *comments = [feedItem.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    int numComments = 1;
    int totalComments = [comments count];
    for (Comment *comment in comments) {
        if(!reviewComment) {
            reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, yOffset, BUBBLE_VIEW_WIDTH, 60.0)];
            [reviewComment setReviewText:comment.comment];
            yOffset += reviewComment.frame.size.height + USER_COMMENT_MARGIN;
            [reviewComment setProfilePhotoWithUrl:feedItem.checkin.user.remoteProfilePhotoUrl];
            if (totalComments == numComments)
                reviewComment.isLastComment = YES;
            [cell addSubview:reviewComment];
            numComments++;
            continue;
        }
        
        NSLog(@"Comment #%d: %@", commentNumber, comment.comment);
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
    
    
    cell.postCardPlaceTitle.text = feedItem.checkin.place.title;
    
    if ([feedItem.meLiked boolValue]) {
        cell.favoriteButton.selected = YES;
    } else {
        cell.favoriteButton.selected = NO;
    }
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateNormal];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateSelected];
    [cell.favoriteButton setTitle:[feedItem.favorites stringValue] forState:UIControlStateHighlighted];
    // Set postcard image
    [cell.postcardPhoto setPostcardPhotoWithURL:[feedItem.checkin firstPhoto].url];
    
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
    if (feedItem.checkin.review) {
        BubbleCommentView *reviewComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, 60.0)];
        [reviewComment setReviewText:feedItem.checkin.review];
        totalHeight += reviewComment.frame.size.height;
    }
    
    for (Comment *comment in feedItem.comments) {
        
        BubbleCommentView *userComment = [[BubbleCommentView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_X_OFFSET, totalHeight, BUBBLE_VIEW_WIDTH, 60.0)];
        userComment.commentLabel.text = comment.comment;
        [userComment setCommentText:comment.comment];
        totalHeight += userComment.frame.size.height;
    }

    return totalHeight;    
}

- (void)fetchResults {
    [RestFeedItem loadFeed:^(NSArray *feedItems) 
                {
                    for (RestFeedItem *feedItem in feedItems) {
                        NSLog(@"creating feeditem for %d", feedItem.externalId);
                        [FeedItem feedItemWithRestFeedItem:feedItem inManagedObjectContext:self.managedObjectContext];
                    }
                    [self saveContext];
                    [self.tableView reloadData];
                }
                onError:^(NSString *error) {
                    NSLog(@"Problem loading feed %@", error);
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


- (IBAction)didLike:(id)sender event:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"ME LIKED IS %d", [feedItem.meLiked integerValue]);
    if ([feedItem.meLiked boolValue]) {
        [feedItem unlike:^(RestFeedItem *restFeedItem) {
            feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
            
            NSLog(@"ME LIKED (REST) IS %d", restFeedItem.meLiked);
            feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
        } onError:^(NSString *error) {
            NSLog(@"Error unliking feed item %@", error);
            [SVProgressHUD showErrorWithStatus:error duration:1.0];
        }];
    } else {
        [feedItem like:^(RestFeedItem *restFeedItem)
         {
             NSLog(@"saving favorite counts with %d", restFeedItem.favorites);
             feedItem.favorites = [NSNumber numberWithInt:restFeedItem.favorites];
             feedItem.meLiked = [NSNumber numberWithInteger:restFeedItem.meLiked];
         }
               onError:^(NSString *error)
         {
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

- (IBAction)didPressProfilePhoto:(id)sender event:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: location];
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"UserShow" sender:feedItem];
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

@end
