//
//  LikesShowViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/17/12.
//
//

#import "LikesShowViewController.h"
#import "User.h"
#import "LikerCell.h";
@interface LikesShowViewController ()

@end

@implementation LikesShowViewController

#pragma mark - UIViewController lifecycle 
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFetchedResultsController];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [cell.profilePhoto setProfileImageForUser:user];
    cell.nameLabel.text = user.normalFullName;
    return cell;
}



@end
