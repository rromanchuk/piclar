//
//  PlaceShowViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceShowViewController.h"
#import "UIBarButtonItem+Borderless.h"
#import "PhotosIndexViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "Place+Rest.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "Photo.h"
#import "PostCardImageView.h"
#import "BaseView.h"
#import "PlaceMapShowViewController.h"
#import "Utils.h"
#define USER_REVIEW_PADDING 5.0f

@interface PlaceShowViewController ()

@end

@implementation PlaceShowViewController
@synthesize backButton;
@synthesize managedObjectContext;
@synthesize postCardPhoto;
@synthesize mapButton;
@synthesize shareButton;
@synthesize photosScrollView;
@synthesize placeTitle;
@synthesize placeTypeIcon;
@synthesize placeAddressLabel;
@synthesize star0;
@synthesize star1;
@synthesize star2;
@synthesize star3;
@synthesize star4;
@synthesize star5;
@synthesize starsImageView;
@synthesize placeShowView;
@synthesize photos;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.star0 = [UIImage imageNamed:@"stars0"];
        self.star1 = [UIImage imageNamed:@"stars1"];
        self.star2 = [UIImage imageNamed:@"stars2"];
        self.star3 = [UIImage imageNamed:@"stars3"];
        self.star4 = [UIImage imageNamed:@"stars4"];
        self.star5 = [UIImage imageNamed:@"stars5"];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIImage *checkinImage = [UIImage imageNamed:@"checkin.png"];
    UIBarButtonItem *checkinButton = [UIBarButtonItem barItemWithImage:checkinImage target:self action:@selector(didCheckIn:)];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.backButton = backButtonItem;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixed, self.backButton, nil ];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixed, checkinButton, nil];
    [self setPlaceInfo];
    
    DLog(@"number of photos for this place %d", [self.feedItem.checkin.place.photos count]);
    
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"place = %@ and review != nil and review.length > 0", self.feedItem.checkin.place];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.feedItem.checkin.place.photos count] > 1) {
        self.placeShowView.hasScrollView = YES;
        self.postCardPhoto.userInteractionEnabled = YES;
        self.photosScrollView.hidden = NO;
        [self setupScrollView];
    } else {
        self.placeShowView.hasScrollView = NO;
        self.postCardPhoto.userInteractionEnabled = NO;
        [self.placeShowView setFrame:CGRectMake(self.placeShowView.frame.origin.x, self.placeShowView.frame.origin.y, self.placeShowView.frame.size.width, self.placeShowView.frame.size.height - self.photosScrollView.frame.size.height)];
        self.photosScrollView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.feedItem.checkin.place.title;
    [self setupFetchedResultsController];
    [self updateResults];
    
    [Flurry logEvent:@"SCREEN_PLACE_SHOW"];
}

- (void)viewDidUnload
{
  
    [self setBackButton:nil];
    [self setPostCardPhoto:nil];
    [self setMapButton:nil];
    [self setShareButton:nil];
    [self setPhotosScrollView:nil];
    [self setPlaceTitle:nil];
    [self setPlaceTypeIcon:nil];
    [self setPlaceAddressLabel:nil];
    [self setStar1:nil];
    [self setStar2:nil];
    [self setStar3:nil];
    [self setStar4:nil];
    [self setStar5:nil];
    [self setStarsImageView:nil];
    [self setPlaceShowView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlacePhotosShow"])
    {
        PhotosIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        DLog(@"number of photos before seque %d", [self.feedItem.checkin.place.photos count]);
        vc.photos = self.photos;
        vc.selectedPhotoIndex = self.postCardPhoto.tag;
        vc.place = self.feedItem.checkin.place;
        DLog(@"index is %d", vc.selectedPhotoIndex);
    } else if ([[segue identifier] isEqualToString:@"MapShow"]) {
        PlaceMapShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.place = self.feedItem.checkin.place;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *identifier = @"PlaceReviewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    } else {
        // Remove manually added subviews from reused cells
        for (UIView *subview in [cell subviews]) {
            if (subview.tag == 999) {
                DLog(@"Found a bubble comment, removing.");
                [subview removeFromSuperview];
            }
        }
    }
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
    return 0;
}

- (UIImage *)setStars:(int)rating {
    if (rating == 0) {
        return self.star0;
    }
    else if (rating == 1) {
        return self.star1;
    } else if (rating == 2) {
        return self.star2;
    } else if (rating == 3) {
        return self.star3;
    } else if (rating == 4) {
        return self.star4;
    } else {
        return self.star0;
    }
}


- (IBAction)didSelectImage:(id)sender {
    DLog(@"did select image");
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *) sender;
    self.postCardPhoto.image = ((PostCardImageView *) tap.view).image;
    self.postCardPhoto.tag = ((PostCardImageView *) tap.view).tag;
}

- (void)setupScrollView {
    self.photosScrollView.showsHorizontalScrollIndicator = NO;
    
    int offsetX = 10;
    int index = 0;
    for (Photo *photo in self.photos) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectImage:)];
        PostCardImageView *photoView = [[PostCardImageView alloc] initWithFrame:CGRectMake(offsetX, 0.0, 68.0, 67.0)];
        [photoView setPostcardPhotoWithURL:photo.url];
        photoView.backgroundColor = [UIColor blackColor];
        photoView.userInteractionEnabled = YES;
        [photoView addGestureRecognizer:tap];
        photoView.tag = index;
        [self.photosScrollView addSubview:photoView];
        offsetX += 10 + photoView.frame.size.width;
        index++;
    }
    
    [self.photosScrollView setContentSize:CGSizeMake(offsetX, 68)];
}

- (void)updateResults {
    [RestPlace loadByIdentifier:self.feedItem.checkin.place.externalId onLoad:^(RestPlace *restPlace) {
        [self.feedItem.checkin.place updatePlaceWithRestPlace:restPlace];
        [self setPlaceInfo];
    } onError:^(NSString *error) {
        DLog(@"Problem updating place: %@", error);
    }];
}

- (void)setPlaceInfo {
    [self.postCardPhoto setPostcardPhotoWithURL:[self.feedItem.checkin.place firstPhoto].url];
    [self setStars:[self.feedItem.checkin.place.rating intValue]];
    DLog(@"Rating is %d", [self.feedItem.checkin.place.rating intValue]);
    [self.starsImageView setImage:[self setStars:[self.feedItem.checkin.place.rating intValue]]];
    self.placeAddressLabel.text = self.feedItem.checkin.place.address;
    self.placeTitle.text = self.feedItem.checkin.place.title;
    DLog(@"place type is %d", [self.feedItem.checkin.place.typeId integerValue]);
    self.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
    
    self.photos = [self.feedItem.checkin.place.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"externalId" ascending:YES]]];
    
    
}

- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}


@end
