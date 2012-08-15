//
//  CheckinCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/15/12.
//
//

#import "CheckinCreateViewController.h"
#import "Place.h"
#import "RestCheckin.h"
#import <QuartzCore/QuartzCore.h>

@interface CheckinCreateViewController ()

@end

@implementation CheckinCreateViewController
@synthesize managedObjectContext;
@synthesize place;
@synthesize filteredImage;
@synthesize reviewTextField;
@synthesize star1Button, star2Button, star3Button, star4Button, star5Button;
@synthesize checkinButton;
@synthesize selectedRating;
@synthesize  placeAddressLabel;
@synthesize placeTitleLabel;
@synthesize placeTypeImage;
@synthesize placeView;
@synthesize postCardImageView;
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
    [self.placeView.layer setCornerRadius:5.0];
    self.postCardImageView.image = self.filteredImage;
    
    if (self.place) {
        self.placeTitleLabel.text = place.title;
        self.placeAddressLabel.text = place.address;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}


- (void)viewDidUnload {
    [self setPostCardImageView:nil];
    [self setReviewTextField:nil];
    [self setStar1Button:nil];
    [self setStar2Button:nil];
    [self setStar3Button:nil];
    [self setStar4Button:nil];
    [self setStar5Button:nil];
    [self setCheckinButton:nil];
    [self setPlaceTypeImage:nil];
    [self setPlaceView:nil];
    [self setPlaceTitleLabel:nil];
    [self setPlaceAddressLabel:nil];
    [super viewDidUnload];
}

- (void)createCheckin {
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in")];
    [RestCheckin createCheckinWithPlace:self.place.externalId
                               andPhoto:self.filteredImage
                             andComment:self.reviewTextField.text
                              andRating:[self.selectedRating integerValue]
                                 onLoad:^(RestCheckin *checkin) {
                                     [SVProgressHUD dismiss];
                                     NSLog(@"");
                                 }
                                onError:^(NSString *error) {
                                    [SVProgressHUD dismissWithError:error];
                                    NSLog(@"Error creating checkin: %@", error);
                                }];
    
}

- (IBAction)didPressCheckin:(id)sender {
    [self createCheckin];
}

@end
