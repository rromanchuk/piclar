//
//  CommentCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//

#import "HPGrowingTextView.h"
#import "FeedItem.h"
#import "Notification.h"
#import "CreatePhotoViewController.h"
#import "NewCommentCell.h"
#import "TTTAttributedLabel.h"
#import "BaseViewController.h"
#import "LikersBanner.h"
@interface CommentCreateViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, CreateCheckinDelegate, NSFetchedResultsControllerDelegate, HPGrowingTextViewDelegate>

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (void)performFetch;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) HPGrowingTextView *commentView;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet LikersBanner *likersBanner;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *disclosureIndicator;


- (IBAction)didAddComment:(id)sender event:(UIEvent *)event;
- (IBAction)didLike:(id)sender event:(UIEvent *)event;
@end
