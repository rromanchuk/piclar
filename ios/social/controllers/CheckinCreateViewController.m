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
@synthesize selectRatingLabel;
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
#warning DRY THIS SHIT UP!!
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *leftFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *rightFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixed.width = 5;
    rightFixed.width = 10;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButtonItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightFixed, dismissButtonItem, nil];
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
    self.postCardImageView.image = self.filteredImage;
    [self.postCardImageView.activityIndicator stopAnimating];
    self.selectRatingLabel.text = NSLocalizedString(@"SET_RATING", @"Direction on how to set rating");
    
    [self.checkinButton setTitle:NSLocalizedString(@"FINISH_CHECKIN_BUTTON", @"Button to submit the checkin") forState:UIControlStateNormal];
    [self.checkinButton setTitle:NSLocalizedString(@"FINISH_CHECKIN_BUTTON", @"Button to submit the checkin") forState:UIControlStateHighlighted];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(self.postCardImageView.frame.origin.x, self.star1Button.frame.origin.y + self.star1Button.frame.size.height + 5.0, self.postCardImageView.frame.size.width, 30.0)];
    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    [self.textView setEnablesReturnKeyAutomatically:NO];
    self.textView.delegate = self;
    self.textView.tag = 50;
    [self.view addSubview:self.textView];
    
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
    [self.textView resignFirstResponder];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 440.0;
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
    [self setSelectRatingLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceSearch"])
    {
        PlaceSearchViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.placeSearchDelegate = self;
    }
}

- (void)createCheckin {
    self.checkinButton.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in")];
    [RestCheckin createCheckinWithPlace:self.place.externalId
                               andPhoto:self.filteredImage
                             andComment:self.textView.text
                              andRating:self.selectedRating
                                 onLoad:^(RestFeedItem *restFeedItem) {
                                     [SVProgressHUD dismiss];
                                     [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                                     [self.delegate didFinishCheckingIn];
                                 }
                                onError:^(NSString *error) {
                                    self.checkinButton.enabled = YES;
                                    [SVProgressHUD dismissWithError:error];
                                    DLog(@"Error creating checkin: %@", error);
                                }];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
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
    DLog(@"didSelectNewPlace");
    if (newPlace) {
        self.place = newPlace;
        self.placeTitleLabel.text = place.title;
        self.placeAddressLabel.text = place.address;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    keyboardShown = NO;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //[self setViewMovedUp:NO kbSize:kbSize.height];
    
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    DLog(@"keyboard shown");
    keyboardShown = YES;
    [self.tableView setScrollEnabled:YES];
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //[self setViewMovedUp:YES kbSize:kbSize.height];
    
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [self.textView setText:@""];
}


- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [self.textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    [self.checkinButton setFrame:CGRectMake(self.checkinButton.frame.origin.x, self.checkinButton.frame.origin.y + (height - self.textView.frame.size.height), self.checkinButton.frame.size.width, self.checkinButton.frame.size.height)];
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (keyboardShown)
//        [self.textView resignFirstResponder];
//}

- (IBAction)dismissModal:(id)sender {
    DLog(@"DISMISSING MODAL");
    [self.delegate didFinishCheckingIn];
}

@end
