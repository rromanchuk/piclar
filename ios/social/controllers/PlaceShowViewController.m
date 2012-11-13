//
//  PlaceShowViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceShowViewController.h"
#import "UIBarButtonItem+Borderless.h"
// Controllers
#import "PhotosIndexViewController.h"
#import "CheckinViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "Place+Rest.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "Photo.h"
#import "BaseView.h"
#import "PlaceMapShowViewController.h"
#import "Utils.h"
#import "CheckinCollectionViewCell.h"
#import "MapAnnotation.h"

#import <QuartzCore/QuartzCore.h>


@interface PlaceShowViewController () {
    BOOL feedLayout;
}

@end

@implementation PlaceShowViewController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        feedLayout = NO;
        needsBackButton = YES;
        needsCheckinButton = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    DLog(@"number of photos for this place %d", [self.feedItem.checkin.place.photos count]);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupView) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    self.title = self.feedItem.checkin.place.title;
    [self setupView];
    [self fetchResults];
    [self setupMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupMap];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
    
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"place = %@", self.feedItem.checkin.place];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MapShow"]) {
        PlaceMapShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.place = self.feedItem.checkin.place;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItem = ((Checkin *)sender).feedItem;
        vc.currentUser = self.currentUser;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    }
}

- (void)setupView {
    ALog(@"In setupview!!");
    if (self.headerView) {
        self.headerView.titleLabel.text = self.feedItem.checkin.place.title;
        self.headerView.locationLabel.text = [self.feedItem.checkin.place cityCountryString];
        

        [self.headerView.switchLayoutButton addTarget:self action:@selector(didSwitchLayout:) forControlEvents:UIControlEventTouchUpInside];
        self.headerView.switchLayoutButton.selected = feedLayout;
        self.headerView.typeImage.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
        
        [self.headerView.mapView.layer setCornerRadius:10.0];
        [self.headerView.mapView.layer setBorderWidth:1.0];
        [self.headerView.mapView.layer setBorderColor:RGBCOLOR(204, 204, 204).CGColor];
        
        [self setStars:[self.feedItem.checkin.place.rating integerValue]];

#warning not a true count..fix
        int checkins = [[self.fetchedResultsController fetchedObjects] count];
        if (checkins > 4) {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        } else if (checkins > 1) {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SECONDARY_PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        } else {
            [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SINGLE_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
        }

    }
    
    
    [self.collectionView reloadData];
}


- (void)setupMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude  = [self.feedItem.checkin.place.lat doubleValue];
    zoomLocation.longitude = [self.feedItem.checkin.place.lon doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.headerView.mapView regionThatFits:viewRegion];
    [self.headerView.mapView setRegion:adjustedRegion animated:NO];
    
    
    CLLocationCoordinate2D placeLocation;
    placeLocation.latitude = [self.feedItem.checkin.place.lat doubleValue];
    placeLocation.longitude = [self.feedItem.checkin.place.lon doubleValue];
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithName:self.feedItem.checkin.place.title address:self.feedItem.checkin.place.address coordinate:placeLocation];
    [self.headerView.mapView addAnnotation:annotation];
    
}


#pragma mark - UICollectionViewDelegate
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"CheckinCollectionCell";
    CheckinCollectionViewCell *cell = (CheckinCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.checkinPhoto setCheckinPhotoWithURL:checkin.firstPhoto.url];
    return cell;
}


- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (feedLayout) {
        return CGSizeMake(310, 310);
    } else {
        return CGSizeMake(100, 100);
    }
}

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"CheckinShow" sender:checkin];
}


- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PlaceShowHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                     PSTCollectionElementKindSectionHeader withReuseIdentifier:@"PlaceShowHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    return self.headerView;
}



- (void)fetchResults {
    [RestPlace loadByIdentifier:self.feedItem.checkin.place.externalId onLoad:^(RestPlace *restPlace) {
        [Place placeWithRestPlace:restPlace inManagedObjectContext:self.managedObjectContext];
        [self setupView];
    } onError:^(NSString *error) {
        DLog(@"Problem updating place: %@", error);
    }];
}



- (IBAction)didSwitchLayout:(id)sender {
    ALog(@"did switch layout");
    feedLayout = !((UIButton *)sender).selected;
    if (feedLayout) {
        ALog(@"FEED LAYOUT");
    } else {
        ALog(@"GRID LAYOUT");
    }
    [self setupView];
}


- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}




- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}

#pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didCanceledCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}


#warning not dry, exists in FeedCell.m
- (void)setStars:(NSInteger)stars {
    self.headerView.star1.highlighted = YES;
    self.headerView.star2.highlighted = self.headerView.star3.highlighted = self.headerView.star4.highlighted = self.headerView.star5.highlighted = NO;
    if (stars == 5) {
        self.headerView.star2.highlighted = self.headerView.star3.highlighted = self.headerView.star4.highlighted = self.headerView.star5.highlighted = YES;
    } else if (stars == 4) {
        self.headerView.star2.highlighted = self.headerView.star3.highlighted = self.headerView.star4.highlighted = YES;
    } else if (stars == 3) {
        self.headerView.star2.highlighted = self.headerView.star3.highlighted = YES;
    } else {
        self.headerView.star2.highlighted = YES;
    }
}
@end
