//
//  LeftViewController.m
//  Piclar
//
//  Created by Ryan Romanchuk on 6/12/13.
//
//

#import "LeftViewController.h"
#import "SettingsRowCell.h"
#import <ViewDeck/IIViewDeckController.h>
#import "UIFont+DEFAULTS.h"
#import "ApplicatonNavigationController.h"
@interface LeftViewController ()

@end

@implementation LeftViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return numOKPaymentCellRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsRowCell";
    SettingsRowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.labelView.font = [UIFont defaultFont:15];
    // Configure the cell...
    if (indexPath.row == LeftViewRowTypeFeed) {
        cell.imageView.image = [UIImage imageNamed:@"feed_icon"];
        cell.labelView.text = @"Лента";
    } else if (indexPath.row == LeftViewRowTypeProfile) {
        cell.imageView.image = [UIImage imageNamed:@"profile_icon"];
        cell.labelView.text = @"Профиль ";
    } else if (indexPath.row == LeftViewRowTypeAboutUs) {
        cell.imageView.image = [UIImage imageNamed:@"about_icon"];
        cell.labelView.text = @"О программе";
    } else if (indexPath.row == LeftViewRowTypeNotifications) {
        cell.imageView.image = [UIImage imageNamed:@"notifications_icon"];
        cell.labelView.text = @"Уведомления";
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALog(@"did tap row with delegate %@", self.delegate);
    ALog(@"parent is %@", self.parentViewController);
    [self.delegate doesNeedSegueFor:@"feed" sender:self];
    
    
    if (indexPath.row == LeftViewRowTypeFeed) {
        [self.viewDeckController toggleLeftViewAnimated:YES];
    } else if (indexPath.row == LeftViewRowTypeProfile) {
        [self.viewDeckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
            UINavigationController *nc = (UINavigationController *)controller.centerController;
            [nc.visibleViewController performSegueWithIdentifier:@"UserShow" sender:self];
            //[n performSegueWithIdentifier:@"UserShow" sender:self];
        }];
    } else if (indexPath.row == LeftViewRowTypeNotifications) {
        [self.viewDeckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
            UINavigationController *nc = (UINavigationController *)controller.centerController;
            [nc.visibleViewController performSegueWithIdentifier:@"Notifications" sender:self];
            //[n performSegueWithIdentifier:@"UserShow" sender:self];
        }];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
