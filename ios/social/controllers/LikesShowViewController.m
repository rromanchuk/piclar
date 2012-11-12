//
//  LikesShowViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import "LikesShowViewController.h"
#import "User.h"
#import "LikerCell.h"
#import "NewUserViewController.h"
@interface LikesShowViewController ()

@end

@implementation LikesShowViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

#pragma mark - UIViewController lifecycle 
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
    self.title = NSLocalizedString(@"LIKERS_TITLE", "Title for likers table");
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UserShow"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        NewUserViewController *vc = (NewUserViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        User *user = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];        
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
        vc.user = user;
        vc.currentUser = self.currentUser;
    }
}

#pragma mark - FRC setup
- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastname" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"self IN %@", self.feedItem.liked];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}



#pragma mark - UITableViewController delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *identifier = @"LikerCell";
    LikerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[LikerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.followButton.hidden = user.isCurrentUser;
    cell.followButton.selected = [user.isFollowed boolValue];
    [cell.profilePhoto setProfileImageForUser:user];
    cell.nameLabel.text = user.normalFullName;
    cell.locationLabel.text = user.location;
    cell.followButton.tag = indexPath.row;
    return cell;
}

# pragma mark - ProfileShowDelegate
- (void)didDismissProfile {
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)followUnfollowUser:(id)sender {
    UIButton *followButton = (UIButton *)sender;
    int row = followButton.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    User *c_user;
    c_user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    DLog(@"got user %@", c_user);
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
    c_user.isFollowed = [NSNumber numberWithBool:![c_user.isFollowed boolValue]];
    followButton.selected = !followButton.selected;
    if (followButton.selected) {
        [self.currentUser addFollowingObject:c_user];
        
        [RestUser followUser:c_user.externalId onLoad:^(RestUser *restUser) {
            [SVProgressHUD dismiss];
        } onError:^(NSString *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } else {
        [self.currentUser removeFollowingObject:c_user];
        [RestUser unfollowUser:c_user.externalId onLoad:^(RestUser *restUser) {
            [SVProgressHUD dismiss];
        } onError:^(NSString *error) {
            followButton.selected = !followButton.selected;
            c_user.isFollowed = [NSNumber numberWithBool:!followButton.selected];
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error];
        }];
        
    }
    
    //[self saveContext];
    [self.tableView reloadData];
}


@end
