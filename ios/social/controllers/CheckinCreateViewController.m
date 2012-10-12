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
#import "WarningBannerView.h"
#import "Utils.h"
@interface CheckinCreateViewController ()

@end

@implementation CheckinCreateViewController
@synthesize managedObjectContext;
@synthesize place;
@synthesize filteredImage;

@synthesize selectedRating;
@synthesize postCardImageView;

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
       leftFixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:leftFixed, backButtonItem, nil];
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.postCardImageView.image = self.filteredImage;
    [self.postCardImageView.activityIndicator stopAnimating];
    
    
    [self.selectPlaceButton setTitle:self.place.title forState:UIControlStateNormal];
    //self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(self.postCardImageView.frame.origin.x, self.star1Button.frame.origin.y + self.star1Button.frame.size.height + 5.0, self.postCardImageView.frame.size.width, 30.0)];
    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    [self.textView setEnablesReturnKeyAutomatically:NO];
    self.textView.delegate = self;
    self.textView.tag = 50;
    //[self.view addSubview:self.textView];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"SCREEN_CHECKIN_CREATE"];
    // No best guess was found, force the user to select a place.
    if (!self.place) {
        [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
    if (![CLLocationManager locationServicesEnabled]) {
        UIView *warningBanner = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_LOCATION_SERVICES", @"User needs to have location services turned for this to work")];
        [self.view addSubview:warningBanner];
    }
        
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.textView resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSelectPlaceButton:nil];
    [self setSelectRatingButton:nil];
    [self setRatingsPickerView:nil];
    [self setSaveButton:nil];
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
    if (!self.selectedRating) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_RATING", @"Message for when validation failed from missing rating")];
        return;
    } else if (!self.place) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_PLACE", @"Message for missing place")];
        return;
    }
    
    //self.checkinButton.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in") maskType:SVProgressHUDMaskTypeBlack];
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
                                    //self.checkinButton.enabled = YES;
                                    [SVProgressHUD showErrorWithStatus:error];
                                    DLog(@"Error creating checkin: %@", error);
                                }];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    return YES;
}

- (IBAction)didPressCheckin:(id)sender {
    [Flurry logEvent:@"CHECKIN_SUBMITED"];
    [self createCheckin];
}

- (IBAction)didPressRating:(id)sender {
    NSInteger rating = ((UIButton *)sender).tag;
    self.selectedRating = [NSNumber numberWithInt:rating];
    
    [Flurry logEvent:@"CHECKIN_RATE_SELECTED" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.selectedRating, @"rating", nil]];
    
    for (int i = 1; i < 6; i++) {
        ((UIButton *)[self.view viewWithTag:i]).selected = NO;
    }
    
    ((UIButton *)sender).selected = YES;
    
    for (int i = 1; i < rating; i++) {
        ((UIButton *)[self.view viewWithTag:i]).selected = YES;
    }
}

#pragma mark PlaceSearchDelegate methods
- (void)didSelectNewPlace:(Place *)newPlace {
    [Flurry logEvent:@"CHECKIN_NEW_PLACE_SELECTED"];
    [Location sharedLocation].delegate = self;
    DLog(@"didSelectNewPlace");
    if (newPlace) {
        self.place = newPlace;
        [self.selectPlaceButton setTitle:place.title forState:UIControlStateNormal];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapSelectPlace:(id)sender {
    [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
}

- (IBAction)didTapSelectRating:(id)sender {
    [self.textView resignFirstResponder];
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
    //[self.checkinButton setFrame:CGRectMake(self.checkinButton.frame.origin.x, self.checkinButton.frame.origin.y + (height - self.textView.frame.size.height), self.checkinButton.frame.size.width, self.checkinButton.frame.size.height)];
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (keyboardShown)
//        [self.textView resignFirstResponder];
//}

- (IBAction)dismissModal:(id)sender {
    DLog(@"DISMISSING MODAL");
#warning this delegate may be getting released if its parent view gets dealloc'd, maybe use notifcation center to push these messages through the stack
    if ([self.delegate respondsToSelector:@selector(didCanceledCheckingIn)]) {
        [self.delegate didCanceledCheckingIn];
    } else {
        [Flurry logError:@"MISSING_DELEGATE_ON_CHECKIN" message:@"" error:nil];
        assert(@"MISSING DELEGATE CAN'T DISMISS MODAL");
    }
}

- (void)applyPhotoTitle {
    
}

#pragma mark - PickerDelegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *label;
    switch (row) {
        case 0:
            label = @"★";
            break;
        case 1:
            label = @"★★";
            break;
        case 2:
            label = @"★★★";
            break;
        case 3:
            label = @"★★★★";
            break;
        case 4:
            label = @"★★★★★";
            break;
        default:
            break;
    }
    return label;

}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    DLog(@"did pick row");
    self.selectedRating = [NSNumber numberWithInteger:row + 1];
    [self.textView becomeFirstResponder];
    switch (row) {
        case 0:
            [self.selectRatingButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%dstar-button.png", row + 1]] forState:UIControlStateNormal];
            break;
        case 1:
            [self.selectRatingButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%dstar-button.png", row + 1]] forState:UIControlStateNormal];
            break;
        case 2:
            [self.selectRatingButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%dstar-button.png", row + 1]] forState:UIControlStateNormal];
            break;
        case 3:
            [self.selectRatingButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%dstar-button.png", row + 1]] forState:UIControlStateNormal];
            break;
        case 4:
            [self.selectRatingButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%dstar-button.png", row + 1]] forState:UIControlStateNormal];
            break;
        default:
            break;
    }

}

@end
