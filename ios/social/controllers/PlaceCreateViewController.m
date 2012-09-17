//
//  PlaceCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import "PlaceCreateViewController.h"

@interface PlaceCreateViewController ()

@end

@implementation PlaceCreateViewController
@synthesize delegate;

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
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:fixed, dismissButtonItem, nil]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)dismissModal:(id)sender {
    [self.delegate didCancelPlaceCreation];
}


@end
