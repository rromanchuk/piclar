//
//  FeedIndexViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/8/12.
//
//

#import "CoreDataTableViewController.h"
#import "PhotoNewViewController.h"
#import "RestClient.h"
#import "NoResultscontrollerViewController.h"
#import "NewUserViewController.h"
#import "ODRefreshControl.h"
#import "NotificationChangesDelegate.h"
#import "LoadMoreFooter.h"
#import "FeedIndexNoResults.h"
@interface FeedIndexViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, CreateCheckinDelegate, NetworkReachabilityDelegate, NoResultsModalDelegate, UIGestureRecognizerDelegate> {
    
    NotificationChangesDelegate *_notificationChangesDelegate;
    NSFetchedResultsController *_notificationFetchedResultController;
    
}


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) LoadMoreFooter *footerView;
@property (strong, nonatomic) FeedIndexNoResults *noResultsFooterView;

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, strong) ODRefreshControl *refreshControl;

- (void)networkReachabilityDidChange:(BOOL)connected;
- (IBAction)didSelectSettings:(id)sender;
- (IBAction)didCheckIn:(id)sender;
- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;
- (IBAction)didPressProfilePhoto:(id)sender;
- (IBAction)didTapPostCard:(id)sender;
@end
