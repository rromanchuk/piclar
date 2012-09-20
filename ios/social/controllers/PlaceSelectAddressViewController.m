//
//  PlaceSelectAddressViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/20/12.
//
//

#import "PlaceSelectAddressViewController.h"

@interface PlaceSelectAddressViewController ()

@end

@implementation PlaceSelectAddressViewController

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
    
    self.title = NSLocalizedString(@"SELECT_ADDRESS_TITLE", @"title for select address");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.dele
}

- (void)viewDidUnload {
    [self setAddressLabel:nil];
    [self setAddressTextField:nil];
    [self setCityLabel:nil];
    [self setCityTextField:nil];
    [self setTelephoneLabel:nil];
    [self setTelephoneTextField:nil];
    [super viewDidUnload];
}
@end
