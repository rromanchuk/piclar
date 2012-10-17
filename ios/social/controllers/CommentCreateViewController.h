//
//  CommentCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/3/12.
//
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "FeedItem.h"
#import "Notification.h"
#import "PhotoNewViewController.h"
#import "NewCommentCell.h"
#import "CommentHeader.h"
#include "TTTAttributedLabel.h"

@interface CommentCreateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CreateCheckinDelegate, NSFetchedResultsControllerDelegate, HPGrowingTextViewDelegate>

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (void)performFetch;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) User *currentUser;

@property (nonatomic, weak) HPGrowingTextView *commentView;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet CommentHeader *headerView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *disclosureIndicator;


- (IBAction)didAddComment:(id)sender event:(UIEvent *)event;

@end
