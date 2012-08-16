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
#import "PlaceSearchViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "UIImage+Resize.h"
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
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    [self.placeView.layer setCornerRadius:5.0];
    self.postCardImageView.image = [self.filteredImage croppedImage:self.postCardImageView.frame];

    
    
    if (self.place) {
        self.placeTitleLabel.text = place.title;
        self.placeAddressLabel.text = place.address;
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceSearch"])
    {
        PlaceSearchViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    }
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

- (IBAction)didPressRating:(id)sender {
    NSInteger rating = ((UIButton *)sender).tag;
    self.selectedRating = [NSNumber numberWithInt:rating];
    
    for (int i = 1; i < 6; i++) {
        ((UIButton *)[self.view viewWithTag:i]).selected = NO;
    }
    
    ((UIButton *)sender).selected = YES;
    
    for (int i = 1; i < rating; i++) {
        ((UIButton *)[self.view viewWithTag:i]).selected = YES;
    }
}

- (void)didSelectNewPlace:(Place *)newPlace {
    NSLog(@"didSelectNewPlace");
    self.place = newPlace;
    [self dismissModalViewControllerAnimated:YES];
}

@end
