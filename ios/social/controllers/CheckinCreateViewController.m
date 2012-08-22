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
#import "FeedItem+Rest.h"
#import "RestFeedItem.h"
#import "BaseView.h"
@interface CheckinCreateViewController ()

@end

@implementation CheckinCreateViewController
@synthesize managedObjectContext;
@synthesize place;
@synthesize filteredImage;
@synthesize star1Button, star2Button, star3Button, star4Button, star5Button;
@synthesize checkinButton;
@synthesize selectedRating;
@synthesize placeAddressLabel;
@synthesize placeTitleLabel;
@synthesize placeTypeImage;
@synthesize placeView;
@synthesize postCardImageView;
@synthesize checkinCreateCell;

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
    self.title = NSLocalizedString(@"CREATE_CHECKIN", @"Title for the create checkin page");
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
    self.postCardImageView.image = [self.filteredImage croppedImage:self.postCardImageView.frame];

    [self.checkinButton.titleLabel setText:NSLocalizedString(@"FINISH_CHECKIN_BUTTON", @"Button to submit the checkin")];
    
    if (self.place) {
        self.placeTitleLabel.text = place.title;
        self.placeAddressLabel.text = place.address;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];

}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 380.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (void)viewDidUnload {
    [self setPostCardImageView:nil];
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
    [self setCheckinCreateCell:nil];
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in")];
    [RestCheckin createCheckinWithPlace:self.place.externalId
                               andPhoto:self.filteredImage
                             andComment:self.textView.text
                              andRating:self.selectedRating
                                 onLoad:^(RestFeedItem *restFeedItem) {
                                     [SVProgressHUD dismiss];
                                     [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissModal" object:self];
                                     NSLog(@"Checkin created");
                                 }
                                onError:^(NSString *error) {
                                    [SVProgressHUD dismissWithError:error];
                                    NSLog(@"Error creating checkin: %@", error);
                                }];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.reviewTextField resignFirstResponder];
    return YES;
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
    if (self.place) {
        self.placeTitleLabel.text = place.title;
        self.placeAddressLabel.text = place.address;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //[self setViewMovedUp:NO kbSize:kbSize.height];
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"keyboard shown");
    [self.tableView setScrollEnabled:YES];
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //[self setViewMovedUp:YES kbSize:kbSize.height];
}

@end
