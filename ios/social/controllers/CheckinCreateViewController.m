//
//  CheckinCreateViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/15/12.
//
//

#import "CheckinCreateViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIBarButtonItem+Borderless.h"
#import "UIImage+Resize.h"
#import "Utils.h"

// Controllers
#import "PlaceSearchViewController.h"

// Views
#import "BaseView.h"
#import "WarningBannerView.h"

// CoreData models
#import "Place+Rest.h"
#import "FeedItem+Rest.h"

// REST models
#import "RestFeedItem.h"
#import "RestCheckin.h"
#import "RestPlace.h"

@interface CheckinCreateViewController ()

@end

@implementation CheckinCreateViewController
@synthesize managedObjectContext;
@synthesize place;
@synthesize filteredImage;

@synthesize selectedRating;
@synthesize postCardImageView;


- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder])
    {
        needsBackButton = YES;
    }
    return self;
}

#pragma mark - ViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.title = NSLocalizedString(@"CREATE_CHECKIN", @"Title for the create checkin page");
    self.postCardImageView.image = self.filteredImage;
    [self.postCardImageView.activityIndicator stopAnimating];
    
    if (!self.selectedRating) {
        [self.selectRatingButton setTitle:@"Оцените место" forState:UIControlStateNormal];
    }
    [self.selectPlaceButton setTitle:self.place.title forState:UIControlStateNormal];
    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor grayColor].CGColor];
    //[self.textView setReturnKeyType:UIReturnKeyDone];
    //[self.textView setEnablesReturnKeyAutomatically:NO];
    self.textView.delegate = self;
    self.textView.tag = 50;
    self.textView.text = NSLocalizedString(@"WRITE_REVIEW", nil);
    self.vkShareButton.selected = YES;
    self.fbShareButton.selected = YES;
    
    [self applyPhotoTitle];
    
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
    [self updateResults];
    [self.textFieldHack becomeFirstResponder];
    if (![CLLocationManager locationServicesEnabled]) {
        UIView *warningBanner = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_LOCATION_SERVICES", @"User needs to have location services turned for this to work")];
        [self.view addSubview:warningBanner];
    }
        
    [self.navigationController setNavigationBarHidden:NO animated:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.textView resignFirstResponder];
}


- (void)viewDidUnload {
    [self setSelectPlaceButton:nil];
    [self setSelectRatingButton:nil];
    [self setRatingsPickerView:nil];
    [self setSaveButton:nil];
    [self setVkShareButton:nil];
    [self setFbShareButton:nil];
    [self setTextFieldHack:nil];
    [super viewDidUnload];
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if ([self.textView.text isEqualToString:NSLocalizedString(@"WRITE_REVIEW", nil)]) {
        self.textView.text = @"";
    }
    DLog(@"did begin editing");
}

#pragma mark - Segue
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
    NSString *review = self.textView.text;
    if (!self.selectedRating) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_RATING", @"Message for when validation failed from missing rating")];
        return;
    } else if (!self.place) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_PLACE", @"Message for missing place")];
        return;
    }
    
    if([review isEqualToString:NSLocalizedString(@"WRITE_REVIEW", nil)]) {
        review = @"";
    }
    
    if (self.processedImage) {
        self.filteredImage = self.processedImage;
        UIImageWriteToSavedPhotosAlbum(self.processedImage, self, nil, nil);
    }
    
    NSMutableArray *platforms = [[NSMutableArray alloc] init];
    if (self.vkShareButton.selected) 
        [platforms addObject:@"vkontakte"];
    if (self.fbShareButton.selected)
        [platforms addObject:@"facebook"];
    
    //self.checkinButton.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in") maskType:SVProgressHUDMaskTypeBlack];
    [RestCheckin createCheckinWithPlace:self.place.externalId
                               andPhoto:self.filteredImage
                             andComment:review
                              andRating:self.selectedRating
                            shareOnPlatforms:platforms
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

#pragma mark - User events
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

- (IBAction)didTapSelectPlace:(id)sender {
    [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
}

- (IBAction)didTapSelectRating:(id)sender {
    [self.textView resignFirstResponder];
    [self.textFieldHack resignFirstResponder];
}

- (IBAction)didPressFBShare:(id)sender {
    self.fbShareButton.selected = !self.fbShareButton.selected;
}

- (IBAction)didPressVKShare:(id)sender {
    self.vkShareButton.selected = !self.vkShareButton.selected;
}


#pragma mark PlaceSearchDelegate methods
- (void)didSelectNewPlace:(Place *)newPlace {
    [Flurry logEvent:@"CHECKIN_NEW_PLACE_SELECTED"];
    [Location sharedLocation].delegate = self;
    DLog(@"didSelectNewPlace");
    if (newPlace) {
        self.place = newPlace;
        [self.selectPlaceButton setTitle:place.title forState:UIControlStateNormal];
        [self applyPhotoTitle];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) textViewDidBeginEditing:(UITextView *) textView {
    [self.textView setText:@""];
}


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

- (NSString *)buildCityCountryString {
    NSString *outString;
    if (self.place.cityName && self.place.countryName) {
        outString = [NSString stringWithFormat:@"%@, %@", self.place.cityName, self.place.countryName];
    } else if (self.place.countryName) {
        outString = self.place.countryName;
    } else if (self.place.cityName) {
        outString = self.place.cityName;
    }
    return outString;
}

- (void)applyPhotoTitle {
    if (!self.selectedFrame)
        return;
    
       
    UIImage *image = [self.filteredImage copy];
    UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    DLog(@"adding label with frame %@", self.selectedFrame);
    
    if ([self.selectedFrame isEqualToString:kOstronautFrameType8]) {
        DLog(@"in add label for frame 8");
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 22)];
        labelTitle.text = self.place.title;
        [labelTitle setFont:[UIFont fontWithName:@"Rayna" size:42]];
        [labelTitle drawTextInRect:CGRectMake(10, image.size.height - 80, labelTitle.frame.size.width, labelTitle.frame.size.height)];
        labelTitle.backgroundColor = [UIColor clearColor];
        
        
        UILabel *labelCityCountry = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 50)];
        labelCityCountry.text = [self buildCityCountryString];
        [labelCityCountry setFont:[UIFont fontWithName:@"Rayna" size:24]];
        labelCityCountry.backgroundColor = [UIColor clearColor];
        [labelCityCountry drawTextInRect:CGRectMake(10, image.size.height - 60, labelCityCountry.frame.size.width, labelCityCountry.frame.size.height)];
        
    } else if ([self.selectedFrame isEqualToString:kOstronautFrameType5]) {
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 50)];
        labelTitle.text = self.place.title;
        labelTitle.textAlignment = NSTextAlignmentCenter;
        [labelTitle setFont:[UIFont fontWithName:@"CourierTT" size:28]];
        [labelTitle drawTextInRect:CGRectMake(10, image.size.height - 70, labelTitle.frame.size.width, labelTitle.frame.size.height)];
        labelTitle.backgroundColor = [UIColor clearColor];

        UILabel *labelCityCountry = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 50)];
        labelCityCountry.text = [self buildCityCountryString];
        labelCityCountry.textAlignment = NSTextAlignmentCenter;
        [labelCityCountry setFont:[UIFont fontWithName:@"CourierTT" size:13]];
        labelCityCountry.backgroundColor = [UIColor clearColor];
        [labelCityCountry drawTextInRect:CGRectMake(10, image.size.height - 40, labelCityCountry.frame.size.width, labelCityCountry.frame.size.height)];

    } else if ([self.selectedFrame isEqualToString:kOstronautFrameType2]) {
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 50)];
        labelTitle.text = self.place.title;
        labelTitle.textAlignment = NSTextAlignmentCenter;
        [labelTitle setFont:[UIFont fontWithName:@"Rayna" size:36]];
        [labelTitle drawTextInRect:CGRectMake(10, image.size.height - 80, labelTitle.frame.size.width, labelTitle.frame.size.height)];
        labelTitle.backgroundColor = [UIColor clearColor];

        UILabel *labelCityCountry = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 50)];
        labelCityCountry.text = [self buildCityCountryString];
        labelCityCountry.textAlignment = NSTextAlignmentCenter;
        [labelCityCountry setFont:[UIFont fontWithName:@"Rayna" size:24]];
        labelCityCountry.backgroundColor = [UIColor clearColor];
        [labelCityCountry drawTextInRect:CGRectMake(10, image.size.height - 50, labelCityCountry.frame.size.width, labelCityCountry.frame.size.height)];
    }

    
    self.processedImage  = UIGraphicsGetImageFromCurrentImageContext();
    self.postCardImageView.image = self.processedImage;
    UIGraphicsEndImageContext();
    
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

#pragma mark - CoreData syncing
- (void)updateResults {
    if (!self.place)
        return;
    
    [RestPlace loadByIdentifier:self.place.externalId onLoad:^(RestPlace *restPlace) {
        [self.place updatePlaceWithRestPlace:restPlace];
    } onError:^(NSString *error) {
        DLog(@"Problem updating place: %@", error);
    }];
}


@end
