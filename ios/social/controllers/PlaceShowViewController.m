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
#import "BaseView.h"
#import "PlaceMapShowViewController.h"
#import "Utils.h"
#import "CheckinCollectionViewCell.h"

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
    //[self fetchResults];
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
    request.predicate = [NSPredicate predicateWithFormat:@"place = %@ and review != nil and review.length > 0", self.feedItem.checkin.place];
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
    }

}

- (void)setupView {
    ALog(@"In setupview!!");
    if (self.headerView) {
        self.headerView.titleLabel.text = self.feedItem.checkin.place.title;
        //self.headerView.locationLabel.text = self.feedItem.checkin.place
    }
    
    
    [self.collectionView reloadData];
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
    FeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"CheckinShow" sender:feedItem];
}


- (PSUICollectionReusableView *)collectionView:(PSUICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PlaceShowHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                                     PSTCollectionElementKindSectionHeader withReuseIdentifier:@"PlaceShowHeader" forIndexPath:indexPath];
    self.headerView = headerView;
    return self.headerView;
}



//- (void)updateResults {
//    [RestPlace loadByIdentifier:self.feedItem.checkin.place.externalId onLoad:^(RestPlace *restPlace) {
//        [self.feedItem.checkin.place updatePlaceWithRestPlace:restPlace];
//        [self setPlaceInfo];
//    } onError:^(NSString *error) {
//        DLog(@"Problem updating place: %@", error);
//    }];
//}



- (IBAction)didCheckIn:(id)sender {
    DLog(@"did checkin");
    [self performSegueWithIdentifier:@"Checkin" sender:self];
}

- (void)didFinishCheckingIn {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}
@end
