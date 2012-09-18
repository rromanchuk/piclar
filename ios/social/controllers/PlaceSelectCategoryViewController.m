//
//  PlaceSelectCategoryViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/17/12.
//
//

#import "PlaceSelectCategoryViewController.h"

@interface PlaceSelectCategoryViewController ()

@end

@implementation PlaceSelectCategoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hotelLabel.text = NSLocalizedString(@"HOTEL", @"Hotel category");
    self.restaurantLabel.text = NSLocalizedString(@"RESTAURANT", @"Restaurant category");
    self.attractionLabel.text = NSLocalizedString(@"ATTRACTION", @"Attraction category");
    self.entertainmentLabel.text = NSLocalizedString(@"ENTERTAINMENT", @"Entertainment category");
    self.unknownLabel.text = NSLocalizedString(@"MYSTERY", @"Mystery category");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)viewDidUnload {
    [self setHotelLabel:nil];
    [self setRestaurantLabel:nil];
    [self setAttractionLabel:nil];
    [self setEntertainmentLabel:nil];
    [self setUnknownLabel:nil];
    [super viewDidUnload];
}
@end
