//
//  PlaceShowViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceShowViewController.h"
#import "PlaceReviewDetailCell.h"
#import "PlaceAllReviewsDetailCell.h"
#import "UIBarButtonItem+Borderless.h"
#import "PhotosIndexViewController.h"
#import "RestPlace.h"
#import "Location.h"
#import "Place.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "Photo.h"
#import "PostCardImageView.h"
@interface PlaceShowViewController ()

@end

@implementation PlaceShowViewController
@synthesize backButton;
@synthesize managedObjectContext;
@synthesize postCardPhoto;
@synthesize likeButton;
@synthesize commentButton;
@synthesize mapButton;
@synthesize shareButton;
@synthesize photosScrollView;
@synthesize placeTitle;
@synthesize placeTypeIcon;
@synthesize placeAddressLabel;
@synthesize star1;
@synthesize star2;
@synthesize star3;
@synthesize star4;
@synthesize star5;
@synthesize starsImageView;
@synthesize place;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
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
    
//    [RestPlace loadByIdentifier:[self.feedItem.checkin.place.externalId integerValue] onLoad:^(id object) {
//        NSLog(@"HERE");
//    } onError:^(NSString *error) {
//        NSLog(@"here");
//    }];
    
    self.navigationItem.hidesBackButton = YES;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
    Location *location = [Location sharedLocation];
    NSLog(@"number of photos for this place %d", [self.feedItem.checkin.place.photos count]);
    [self.postCardPhoto setImageWithURL:[NSURL URLWithString:self.feedItem.checkin.firstPhoto.url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [self setStars:[self.feedItem.checkin.place.rating intValue]];
    [self.starsImageView setImage:[self setStars:[self.feedItem.checkin.place.rating intValue]]];
    //[self.starsImageView setImage:self.star2];
    self.placeAddressLabel.text = self.feedItem.checkin.place.address;
    self.placeTitle.text = self.feedItem.checkin.place.title;
    [self setupScrollView];
    //    [RestPlace searchByLat:location.latitude
//                    andLon:location.longitude 
//                    onLoad:^(id object) {
//                        NSLog(@"");
//                    } onError:^(NSString *error) {
//                        NSLog(@"");
//                    }];
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.feedItem.checkin.place.title;
    [self setupFetchedResultsController];
}
- (void)viewDidUnload
{
  
    [self setBackButton:nil];
    [self setPostCardPhoto:nil];
    [self setLikeButton:nil];
    [self setCommentButton:nil];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlacePhotosShow"])
    {
        PhotosIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        NSLog(@"number of photos before seque %d", [self.feedItem.checkin.place.photos count]);
        vc.photos = self.feedItem.checkin.place.photos;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *identifier = @"PlaceReviewDetailCell";
    PlaceReviewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PlaceReviewDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSLog(@"The review of this checkin is: %@", checkin.review);
    NSLog(@"The author of this checkin is: %@", checkin.user.fullName);
    cell.authorLabel.text = checkin.user.fullName;
    cell.reviewLabel.text = checkin.review;
    return cell;
}

- (UIImage *)setStars:(int)rating {
    if (rating == 1) {
        return self.star1;
    } else if (rating == 2) {
        return self.star2;
    } else if (rating == 3) {
        return self.star3;
    } else if (rating == 4) {
        return self.star4;
    } else {
        return self.star5;
    }
}

- (void)setupScrollView {
    int offsetX = 10;
    for (Photo *photo in self.feedItem.checkin.place.photos) {
        PostCardImageView *photoView = [[PostCardImageView alloc] initWithFrame:CGRectMake(offsetX, 0.0, 68.0, 67.0)];
        [photoView setImageWithURL:[NSURL URLWithString:photo.url]];
        photoView.backgroundColor = [UIColor redColor];
        [self.photosScrollView addSubview:photoView];
        offsetX += 10 + photoView.frame.size.width;
    }
    
    [self.photosScrollView setContentSize:CGSizeMake(offsetX, 68)];
}




@end
