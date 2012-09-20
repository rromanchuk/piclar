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
    
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: fixed, backButtonItem, nil];
    
    self.hotelLabel.text = NSLocalizedString(@"HOTEL", @"Hotel category");
    self.restaurantLabel.text = NSLocalizedString(@"RESTAURANT", @"Restaurant category");
    self.attractionLabel.text = NSLocalizedString(@"ATTRACTION", @"Attraction category");
    self.entertainmentLabel.text = NSLocalizedString(@"ENTERTAINMENT", @"Entertainment category");
    self.unknownLabel.text = NSLocalizedString(@"MYSTERY", @"Mystery category");
    
    self.hotelCell.tag = 1;
    self.mysteryCell.tag = 0;
    self.restaurantCell.tag = 2;
    self.attractionCell.tag = 3;
    self.entertainmentCell.tag = 4;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"in did select");
    switch (indexPath.row) {
        case 0:
            [self.delegate didSelectCategory:1];
            break;
        case 1:
            [self.delegate didSelectCategory:2];
            break;
        case 2:
            [self.delegate didSelectCategory:3];
            break;
        case 3:
            [self.delegate didSelectCategory:4];
            break;
        case 4:
            [self.delegate didSelectCategory:0];
            break;
        default:
            break;
    }
}

- (void)viewDidUnload {
    [self setHotelLabel:nil];
    [self setRestaurantLabel:nil];
    [self setAttractionLabel:nil];
    [self setEntertainmentLabel:nil];
    [self setUnknownLabel:nil];
    [self setHotelCell:nil];
    [self setRestaurantCell:nil];
    [self setAttractionCell:nil];
    [self setEntertainmentCell:nil];
    [self setMysteryCell:nil];
    [super viewDidUnload];
}
@end
