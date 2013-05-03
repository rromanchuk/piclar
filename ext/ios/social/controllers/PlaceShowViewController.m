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
#import "CheckinViewController.h"
#import "ApplicatonNavigationController.h"


#import "RestPlace.h"
#import "Location.h"

// Coredata
#import "Place+Rest.h"
#import "FeedItem+Rest.h"

#import "User.h"
#import "Photo.h"
#import "BaseView.h"
#import "PlaceMapShowViewController.h"
#import "Utils.h"
#import "CheckinCollectionViewCell.h"
#import "MapAnnotation.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaceShowFeedCollectionCell.h"

#import "RestFeedItem.h"

#define REVIEW_LABEL_WIDTH 298.0f
#define HEADER_ELEMENT_DEFAULT_HEIGHT 265.0f
#define HEADER_ELEMENT_TITLE_WIDTH 266.0f
#define HEADER_ELEMENT_PADDING 5.0f



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
    [self setupFetchedResultsController];
    [self fetchResults];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.fetchedResultsController)
        [self setupFetchedResultsController];
    [super viewWillAppear:animated];
    self.title = self.place.title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FeedItem"];
    request.predicate = [NSPredicate predicateWithFormat:@"placeId == %@ and isActive == %i", self.place.externalId, YES];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
    
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
        vc.place = self.place;
    } else if ([[segue identifier] isEqualToString:@"Checkin"]) {
        ApplicatonNavigationController *nc = (ApplicatonNavigationController *)[segue destinationViewController];
        nc.isChildNavigationalStack = YES;
        [Flurry logAllPageViews:nc];
        PhotoNewViewController *vc = (PhotoNewViewController *)((UINavigationController *)[segue destinationViewController]).topViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"CheckinShow"]) {
        CheckinViewController *vc = (CheckinViewController *)segue.destinationViewController;
        vc.managedObjectContext = self.managedObjectContext;
        vc.feedItemId = ((FeedItem *)sender).externalId;
        vc.currentUser = self.currentUser;
        vc.deletionDelegate = self;
    }
}

- (void)setupMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude  = [self.place.lat doubleValue];
    zoomLocation.longitude = [self.place.lon doubleValue];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.headerView.mapView regionThatFits:viewRegion];
    [self.headerView.mapView setRegion:adjustedRegion animated:NO];
    
    
    CLLocationCoordinate2D placeLocation;
    placeLocation.latitude = [self.place.lat doubleValue];
    placeLocation.longitude = [self.place.lon doubleValue];
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithName:self.place.title address:self.place.address coordinate:placeLocation];
    [self.headerView.mapView addAnnotation:annotation];
}


#pragma mark - UICollectionViewDelegate
- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"CheckinCollectionCell";
    static NSString *LargeCellIdentifier = @"PlaceShowFeedCollectionCell";

    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (feedLayout) {
        PlaceShowFeedCollectionCell *cell = (PlaceShowFeedCollectionCell *)[cv dequeueReusableCellWithReuseIdentifier:LargeCellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor backgroundColor];
        cell.reviewLabel.backgroundColor = [UIColor backgroundColor];
        [cell.checkinPhoto setFrame:CGRectMake(cell.checkinPhoto.frame.origin.x, cell.checkinPhoto.frame.origin.y, 310, 310)];
        [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.photoUrl];
        cell.reviewLabel.text = feedItem.review;
        
        CGSize expectedCommentLabelSize = [cell.reviewLabel.text sizeWithFont:cell.reviewLabel.font
                                                       constrainedToSize:CGSizeMake(REVIEW_LABEL_WIDTH, CGFLOAT_MAX)                                                       lineBreakMode:UILineBreakModeWordWrap];
        [cell.reviewLabel setFrame:CGRectMake(cell.reviewLabel.frame.origin.x, cell.reviewLabel.frame.origin.y, REVIEW_LABEL_WIDTH, expectedCommentLabelSize.height)];
        return cell;
    } else {
        CheckinCollectionViewCell *cell = (CheckinCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.checkinPhoto setCheckinPhotoWithURL:feedItem.thumbPhotoUrl];
        return cell;
    }    
}


- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (feedLayout) {
        FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, REVIEW_LABEL_WIDTH, CGFLOAT_MAX)];
        sampleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        sampleLabel.text = [NSString stringWithFormat:@"%@", feedItem.review];
        
        CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                       constrainedToSize:CGSizeMake(REVIEW_LABEL_WIDTH, CGFLOAT_MAX)                                                       lineBreakMode:UILineBreakModeWordWrap];
        
        
        DLog(@"Returning expected height of %f", expectedCommentLabelSize.height);
        int totalHeight;
        totalHeight = 334 + expectedCommentLabelSize.height + 5;
        
        return CGSizeMake(310, totalHeight);
    } else {
        return CGSizeMake(98, 98);
    }
}

- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
}

- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, HEADER_ELEMENT_TITLE_WIDTH, CGFLOAT_MAX)];
    sampleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    sampleLabel.text = self.place.title;
    CGSize expectedCommentLabelSize = [sampleLabel.text sizeWithFont:sampleLabel.font
                                                   constrainedToSize:CGSizeMake(HEADER_ELEMENT_TITLE_WIDTH, CGFLOAT_MAX)                                                       lineBreakMode:UILineBreakModeWordWrap];
    if (expectedCommentLabelSize.height > 19) {
        return CGSizeMake(self.headerView.frame.size.width, HEADER_ELEMENT_DEFAULT_HEIGHT + expectedCommentLabelSize.height - 19);
    } else {
        return CGSizeMake(self.headerView.frame.size.width, HEADER_ELEMENT_DEFAULT_HEIGHT );
    }
    
}

- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PlaceShowHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                     PSTCollectionElementKindSectionHeader withReuseIdentifier:@"PlaceShowHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    
    self.headerView.titleLabel.text = self.place.title;
    self.headerView.titleLabel.numberOfLines = 0;
    [self.headerView.titleLabel sizeToFit];
    [self.headerView.titleLabel setFrame:CGRectMake(self.headerView.titleLabel.frame.origin.x, self.headerView.mapView.frame.origin.y + self.headerView.mapView.frame.size.height + 10, HEADER_ELEMENT_TITLE_WIDTH, self.headerView.titleLabel.frame.size.height)];
    [self.headerView.typeImage setFrame:CGRectMake(self.headerView.typeImage.frame.origin.x, self.headerView.mapView.frame.origin.y + self.headerView.mapView.frame.size.height + 10 + ((self.headerView.titleLabel.frame.size.height / 2) - (self.headerView.typeImage.frame.size.height / 2)), self.headerView.typeImage.frame.size.width, self.headerView.typeImage.frame.size.height)];
    
    self.headerView.locationLabel.text = [self.place cityCountryString];
    self.headerView.locationLabel.numberOfLines = 0;
    [self.headerView.locationLabel sizeToFit];
    [self.headerView.locationLabel setFrame:CGRectMake(self.headerView.locationLabel.frame.origin.x, self.headerView.titleLabel.frame.origin.y + self.headerView.titleLabel.frame.size.height + 5, self.headerView.locationLabel.frame.size.width, self.headerView.locationLabel.frame.size.height)];
    
    [self.headerView.star1 setFrame:CGRectMake(self.headerView.star1.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.star1.frame.size.width, self.headerView.star1.frame.size.height)];
    [self.headerView.star2 setFrame:CGRectMake(self.headerView.star2.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.star1.frame.size.width, self.headerView.star1.frame.size.height)];
    [self.headerView.star3 setFrame:CGRectMake(self.headerView.star3.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.star1.frame.size.width, self.headerView.star1.frame.size.height)];
    [self.headerView.star4 setFrame:CGRectMake(self.headerView.star4.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.star1.frame.size.width, self.headerView.star1.frame.size.height)];
    [self.headerView.star5 setFrame:CGRectMake(self.headerView.star5.frame.origin.x, self.headerView.locationLabel.frame.origin.y + self.headerView.locationLabel.frame.size.height + 5, self.headerView.star1.frame.size.width, self.headerView.star1.frame.size.height)];
    
    [self.headerView.switchLayoutButton setFrame:CGRectMake(self.headerView.switchLayoutButton.frame.origin.x, self.headerView.star1.frame.origin.y + self.headerView.star1.frame.size.height + 10, self.headerView.switchLayoutButton.frame.size.width, self.headerView.switchLayoutButton.frame.size.height)];
    
    
    
    [self.headerView.switchLayoutButton addTarget:self action:@selector(didSwitchLayout:) forControlEvents:UIControlEventTouchUpInside];
    self.headerView.switchLayoutButton.selected = feedLayout;
    self.headerView.typeImage.image = [Utils getPlaceTypeImageWithTypeId:[self.place.typeId integerValue]];
    
    [self.headerView.mapView.layer setCornerRadius:10.0];
    [self.headerView.mapView.layer setBorderWidth:1.0];
    [self.headerView.mapView.layer setBorderColor:RGBCOLOR(204, 204, 204).CGColor];
    
    
#warning not a true count..fix
    int checkins = [[self.fetchedResultsController fetchedObjects] count];
    if (checkins > 4) {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    } else if (checkins > 1) {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SECONDARY_PLURAL_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    } else {
        [self.headerView.switchLayoutButton setTitle:[NSString stringWithFormat:@"%d %@", checkins, NSLocalizedString(@"SINGLE_PHOTOGRAPH", nil)] forState:UIControlStateNormal];
    }
    
    [self setupMap];
    //[self.headerView setFrame:CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.switchLayoutButton.frame.origin.y + self.headerView.switchLayoutButton.frame.size.height + 30)];
    return self.headerView;
}



- (void)fetchResults {
    if ([[self.fetchedResultsController fetchedObjects] count] == 0)
        [SVProgressHUD showWithStatus:NSLocalizedString(@"LOADING", nil) maskType:SVProgressHUDMaskTypeGradient];
    
    [self.managedObjectContext performBlock:^{
        self.pauseUpdates = YES;
        [RestPlace loadReviewsWithPlaceId:self.place.externalId onLoad:^(NSSet *reviews) {
            for (RestFeedItem *restFeedItem in reviews) {
                FeedItem *feedItem = [FeedItem feedItemWithRestFeedItem:restFeedItem inManagedObjectContext:self.managedObjectContext];
            }
            
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                // handle error
                ALog(@"error %@", error);
            } else {
                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [sharedAppDelegate writeToDisk];
                [SVProgressHUD dismiss];
                self.pauseUpdates = NO;

                [self.collectionView reloadData];
                
            }
            
        } onError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];

    }];
    
//    NSManagedObjectContext *loadReviewsContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    loadReviewsContext.parentContext = self.managedObjectContext;
//    Place *place = [Place placeWithExternalId:self.place.externalId inManagedObjectContext:loadReviewsContext];
//    [loadReviewsContext performBlock:^{
//        [RestPlace loadReviewsWithPlaceId:place.externalId onLoad:^(NSSet *reviews) {
//            for (RestCheckin *restCheckin in reviews) {
//                ALog(@"review is %@", restCheckin);
//                Checkin *checkin = [Checkin checkinWithRestCheckin:restCheckin inManagedObjectContext:loadReviewsContext];
//                [place addCheckinsObject:checkin];
//            }
//            
//            // push to parent
//            NSError *error;
//            if (![loadReviewsContext save:&error])
//            {
//                // handle error
//                ALog(@"error %@", error);
//            }
//            
//            // save parent to disk asynchronously
//            [self.managedObjectContext performBlock:^{
//                NSError *error;
//                if (![self.managedObjectContext save:&error])
//                {
//                    // handle error
//                    ALog(@"error %@", error);
//                } else {
//                                    
//                }
//                AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                [sharedAppDelegate writeToDisk];
//                //self.pauseUpdates = NO;
//                [self setupView];
//            }];
//
//            
//        } onError:^(NSError *error) {
//            
//        }];
//        
//    }];

}



- (IBAction)didSwitchLayout:(id)sender {
    feedLayout = !((UIButton *)sender).selected;
    [self.collectionView reloadData];
}


- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}


#pragma mark - CreateCheckinDelegate
- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
}

- (void)didCanceledCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
    [NotificationHandler shared].delegate = (ApplicatonNavigationController *)self.navigationController;
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
    } else if (stars == 2) {
        self.headerView.star2.highlighted = YES;
    }
}


#pragma mark CoreData methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *_managedObjectContext = self.managedObjectContext;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    AppDelegate *sharedAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [sharedAppDelegate writeToDisk];
}

#pragma mark - DeletionHandlerDelegate
- (void)deleteFeedItem: (FeedItem *)feedItem {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"DELETING_FEED", @"Loading screen for deleting user's comment") maskType:SVProgressHUDMaskTypeGradient];
    [RestFeedItem deleteFeedItem:feedItem.externalId onLoad:^(RestFeedItem *restFeedItem) {
        [feedItem deactivate];
        [self saveContext];
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
        [((ApplicatonNavigationController *)self.navigationController) back:self];
    } onError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
    
    
}


@end
