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

@interface FeedIndexViewController : CoreDataTableViewController <UITableViewDelegate, UITableViewDataSource, CreateCheckinDelegate, NetworkReachabilityDelegate, NoResultsModalDelegate> {
    
}


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) User *currentUser;

- (void)networkReachabilityDidChange:(BOOL)connected;
- (IBAction)didSelectSettings:(id)sender;
- (IBAction)didCheckIn:(id)sender;
- (IBAction)didLike:(id)sender event:(UIEvent *)event;
- (IBAction)didPressComment:(id)sender event:(UIEvent *)event;
- (IBAction)didPressProfilePhoto:(id)sender;
- (IBAction)didTapPostCard:(id)sender;
@end
