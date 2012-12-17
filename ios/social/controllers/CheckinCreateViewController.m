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
#import <FacebookSDK/FacebookSDK.h>

// Controllers
#import "PlaceSearchViewController.h"

// Views
#import "BaseView.h"
#import "WarningBannerView.h"

// CoreData models
#import "Place+Rest.h"
#import "FeedItem+Rest.h"
#import "UserSettings+Rest.h"

// REST models
#import "RestFeedItem.h"
#import "RestCheckin.h"
#import "RestPlace.h"

#import "AppDelegate.h"
#import "ThreadedUpdates.h"
#import "FoursquareHelper.h"
#import "Vkontakte.h"

// Categories
#import "NSMutableDictionary+ImageMetadata.h"
#import "NSData+Exif.h"
@interface CheckinCreateViewController ()

@end

@implementation CheckinCreateViewController


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

    [self.textView.layer setBorderWidth:1.0];
    [self.textView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.textView setReturnKeyType:UIReturnKeyDone];
    [self.textView setEnablesReturnKeyAutomatically:NO];
    self.textView.delegate = self;
    self.textView.minNumberOfLines = 4;
    self.textView.maxNumberOfLines = 5;
    self.textView.tag = 50;
    self.textView.text = NSLocalizedString(@"WRITE_REVIEW", nil);
    self.selectRatingLabel.text = NSLocalizedString(@"SELECT_RATING", nil);
    self.textView.textColor = [UIColor defaultFontColor];
    self.vkShareButton.selected = YES;
    
    UIImage *dismissButtonImage = [UIImage imageNamed:@"dismiss.png"];
    UIBarButtonItem *dismissButtonItem = [UIBarButtonItem barItemWithImage:dismissButtonImage target:self action:@selector(dismissModal:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:dismissButtonItem, nil]];

    [self applyPhotoTitle];
    
    [[Location sharedLocation] resetDesiredLocation];
    [[Location sharedLocation] updateUntilDesiredOrTimeout:5.0];
    
    self.fbShareButton.selected = [[FacebookHelper shared] canPublishActions];
    self.fsqSharebutton.selected = [[FoursquareHelper shared] sessionIsValid];
    self.vkShareButton.selected = [[Vkontakte sharedInstance] isAuthorized];
    
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"SCREEN_CHECKIN_CREATE"];
    if (self.place) {
        [self.selectPlaceButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"I_AM_AT", "i'am at"), self.place.title] forState:UIControlStateNormal];
    } else {
        [self.selectPlaceButton setTitle:NSLocalizedString(@"PLEASE_SELECT_PLACE", "please select place") forState:UIControlStateNormal];
    }
    // No best guess was found, force the user to select a place.
    if (!self.place && self.isFirstTimeOpen && [[Location sharedLocation] isLocationValid]) {
        self.isFirstTimeOpen = NO;
        [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateResults];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [FacebookHelper shared].delegate = self;
    [Vkontakte sharedInstance].delegate = self;
    [Location sharedLocation].delegate = self;
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}


- (void)viewDidUnload {
    [self setSelectPlaceButton:nil];
    [self setVkShareButton:nil];
    [self setFbShareButton:nil];
    [self setStar1:nil];
    [self setStar2:nil];
    [self setStar3:nil];
    [self setStar4:nil];
    [self setStar5:nil];
    [self setCheckinButton:nil];
    [self setFsqSharebutton:nil];
    [self setClassmateShareButton:nil];
    [self setSelectRatingLabel:nil];
    [super viewDidUnload];
}


- (void)showNoLocationBanner {
    
    UIView *warningBanner = [[WarningBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30) andMessage:NSLocalizedString(@"NO_LOCATION_SERVICES", @"User needs to have location services turned for this to work")];
    [self.view addSubview:warningBanner];
    
}

#pragma mark - HPGrowingTextView delegate methods
-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if ([self.textView.text isEqualToString:NSLocalizedString(@"WRITE_REVIEW", nil)]) {
        self.textView.text = @"";
    }
    DLog(@"did begin editing");
}

-(void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    if(height < 40)
        height = 40.0;
    [self.textView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y - (height - self.textView.frame.size.height ), self.textView.frame.size.width, height)];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlaceSearch"])
    {
        PlaceSearchViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.placeSearchDelegate = self;
        [Location sharedLocation].delegate = vc;
    }
}

- (void)createCheckin {
    NSString *review = self.textView.text;
    if (!self.place) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_PLACE", @"Message for missing place")];
        return;
    }
    if (!self.selectedRating) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MISSING_RATING", @"Message for when validation failed from missing rating")];
        return;
    }
    
    if([review isEqualToString:NSLocalizedString(@"WRITE_REVIEW", nil)]) {
        review = @"";
    }
    
    ALog(@"meta data is currently %@", self.metaData);
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[Location sharedLocation].latitude doubleValue] longitude:[[Location sharedLocation].longitude doubleValue]];
    if (!self.metaData) {
        ALog(@"no meta data, add gps");
        self.metaData = [[NSMutableDictionary alloc] init];
        [self.metaData setLocation:location];
    }
    
    ALog(@"metadata after is %@", self.metaData);
    NSData *imageData;
    if (self.processedImage) {
        [self.metaData setImageOrientarion:self.processedImage.imageOrientation]; 
        imageData = UIImageJPEGRepresentation(self.processedImage, 0.9);
    } else {
        [self.metaData setImageOrientarion:self.filteredImage.imageOrientation];
        imageData = UIImageJPEGRepresentation(self.filteredImage, 0.9);
    }
    NSMutableData *imageDataWithExif = [imageData addExifData:self.metaData];
    
    NSArray  *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageName = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"TestImage.jpg"];
    [imageDataWithExif writeToFile:imageName atomically:YES];
    
    if (self.processedImage && [self.currentUser.settings.saveFiltered boolValue]) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        self.filteredImage = self.processedImage;
        [library writeImageToSavedPhotosAlbum:[self.filteredImage CGImage]
                                     metadata:self.metaData
                              completionBlock:nil];
    }
    
    NSMutableArray *platforms = [[NSMutableArray alloc] init];
    if (self.vkShareButton.selected) 
        [platforms addObject:@"vkontakte"];
        [Flurry logEvent:@"SHARED_ON_VKONTAKTE"];
    if (self.fbShareButton.selected) {
        [platforms addObject:@"facebook"];
        [Flurry logEvent:@"SHARED_ON_FACEBOOK"];
        [[FacebookHelper shared] uploadPhotoToFacebook:self.filteredImage withMessage:review];
        ALog(@"uploading to facebook");
    }
    
    self.checkinButton.enabled = NO;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"CHECKING_IN", @"The loading screen text to display when checking in") maskType:SVProgressHUDMaskTypeBlack];
    [RestCheckin createCheckinWithPlace:self.place.externalId
                               andPhoto:imageDataWithExif
                             andComment:review
                              andRating:self.selectedRating
                            shareOnPlatforms:platforms
                                 onLoad:^(RestFeedItem *restFeedItem) {
                                     [SVProgressHUD dismiss];
                                     FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
                                     ALog(@"new feed item is %@", feedItem);
                                     [self saveContext];
                                     [self.delegate didFinishCheckingIn];
                                 }
                                onError:^(NSError *error) {
                                    self.checkinButton.enabled = YES;
                                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
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


- (IBAction)didTapSelectPlace:(id)sender {
    self.isFirstTimeOpen = NO;
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorized) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NO_LOCATION_SERVICES_ALERT", @"User needs to have location services turned for this to work")];
        [[Location sharedLocation] updateUntilDesiredOrTimeout:0.5];
        return;
    }
    [self performSegueWithIdentifier:@"PlaceSearch" sender:self];
}


- (IBAction)didPressFBShare:(id)sender {
    if (!self.fbShareButton.selected) {
        if (![[FacebookHelper shared] canPublishActions]) {
            DLog(@"Facebook session not open, opening now");
            [[FacebookHelper shared] prepareForPublishing];
        }
    }
    self.fbShareButton.selected = !self.fbShareButton.selected;
}

- (IBAction)didPressVKShare:(id)sender {
    if (!self.vkShareButton.selected) {
        if (![[Vkontakte sharedInstance] isAuthorized])
            [[Vkontakte sharedInstance] authenticate];
    }
    self.vkShareButton.selected = !self.vkShareButton.selected;
}

- (IBAction)didPressFsqShare:(id)sender {
    [[FoursquareHelper shared] authorize];
}

- (IBAction)didPressClassmatesShare:(id)sender {
}


#pragma mark PlaceSearchDelegate methods
- (void)didSelectNewPlace:(Place *)newPlace {
    [Flurry logEvent:@"CHECKIN_NEW_PLACE_SELECTED"];
    [Location sharedLocation].delegate = self;
    DLog(@"didSelectNewPlace");
    if (newPlace) {
        self.place = newPlace;
        [self.selectPlaceButton setTitle:self.place.title forState:UIControlStateNormal];
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
        AppDelegate *theDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [Location sharedLocation].delegate = theDelegate;
        [self.delegate didCanceledCheckingIn];
    } else {
        [Flurry logError:@"MISSING_DELEGATE_ON_CHECKIN" message:@"" error:nil];
        assert(@"MISSING DELEGATE CAN'T DISMISS MODAL");
    }
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
        labelCityCountry.text = [self.place cityCountryString];
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
        labelCityCountry.text = [self.place cityCountryString];
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
        labelCityCountry.text = [self.place cityCountryString];
        labelCityCountry.textAlignment = NSTextAlignmentCenter;
        [labelCityCountry setFont:[UIFont fontWithName:@"Rayna" size:24]];
        labelCityCountry.backgroundColor = [UIColor clearColor];
        [labelCityCountry drawTextInRect:CGRectMake(10, image.size.height - 50, labelCityCountry.frame.size.width, labelCityCountry.frame.size.height)];
    }

    
    self.processedImage  = UIGraphicsGetImageFromCurrentImageContext();
    self.postCardImageView.image = self.processedImage;
    UIGraphicsEndImageContext();
    
}


#pragma mark - CoreData syncing
- (void)updateResults {
    if (!self.place)
        return;
    
    Place *place = self.place;
    [RestPlace loadByIdentifier:self.place.externalId onLoad:^(RestPlace *restPlace) {
        [place updatePlaceWithRestPlace:restPlace];
    } onError:^(NSError *error) {
        DLog(@"Problem updating place: %@", error);
    }];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text isEqualToString:@"\n"]) {
        [growingTextView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (IBAction)didTapSelectRating:(id)sender {
    self.selectedRating = [NSNumber numberWithInteger:((UIView *)sender).tag];
    switch (((UIView *)sender).tag) {
        case 1:
            self.star1.selected = YES;
            self.star2.selected = self.star3.selected = self.star4.selected = self.star5.selected = NO;
            break;
        case 2:
            self.star1.selected = self.star2.selected = YES;
            self.star3.selected = self.star4.selected = self.star5.selected = NO;
            break;
        case 3:
            self.star1.selected = self.star2.selected = self.star3.selected = YES;
            self.star4.selected = self.star5.selected = NO;
            break;
        case 4:
            self.star1.selected = self.star2.selected = self.star3.selected = self.star4.selected = YES;
            self.star5.selected = NO;
            break;
        case 5:
            self.star1.selected = self.star2.selected = self.star3.selected = self.star4.selected  = self.star5.selected = YES;
            break;
        default:
            break;
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - FacebookHelperDelegates methods
- (void)fbSessionValid {
    ALog(@"Facebook session state changed.. delegate called");
    if ([[FacebookHelper shared ] canPublishActions]) {
        self.fbShareButton.selected = YES;
    } else {
        self.fbShareButton.selected = NO;
    }

}

- (void)fbDidFailLogin:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    self.fbShareButton.selected = NO;
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    ALog(@"vk authorization failed");
    [self dismissModalViewControllerAnimated:YES];
    self.vkShareButton.selected = NO;
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled
{
    ALog(@"user canceled auth");
    [self dismissModalViewControllerAnimated:YES];
    self.vkShareButton.selected = NO;
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    self.vkShareButton.selected = YES;
    [RestUser updateProviderToken:vkontakte.accessToken forProvider:@"vkontakte" onLoad:^(RestUser *restUser) {
        self.vkShareButton.selected = YES;
    } onError:^(NSError *error) {
        ALog(@"unable to update vk token %@", error);
        self.vkShareButton.selected = NO;
    }];
    ALog(@"vk auth success");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    DLog(@"USER DID LOGOUT");
}

- (void)vkontakteDidFinishGettinUserInfo:(NSDictionary *)info
{
    DLog(@"GOT USER INFO FROM VK: %@", info);
}


#pragma mark LocationDelegate methods

- (void)locationStoppedUpdatingFromTimeout
{
    //    [Flurry logEvent:@"FAILED_TO_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

- (void)didGetBestLocationOrTimeout
{
    DLog(@"");
    [[ThreadedUpdates shared] loadPlacesPassively];
    //    [Flurry logEvent:@"DID_GET_DESIRED_LOCATION_ACCURACY_APP_LAUNCH"];
}

- (void)failedToGetLocation:(NSError *)error
{
    DLog(@"%@", error);
    //    [Flurry logEvent:@"FAILED_TO_GET_ANY_LOCATION_APP_LAUNCH"];
}
@end
