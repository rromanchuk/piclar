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
#import "PhotoNewViewController.h"
#import "NewCommentCell.h"

@interface CommentCreateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CreateCheckinDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (void)performFetch;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) FeedItem *feedItem;
@property (nonatomic, weak) HPGrowingTextView *commentView;

@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *placeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeTypePhoto;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)didAddComment:(id)sender event:(UIEvent *)event;

@end
