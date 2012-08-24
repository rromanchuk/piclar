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
#import "ReviewBubble.h"
#import "UserComment.h"
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
@synthesize placeShowView;
@synthesize activityIndicator;

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
    
    self.navigationItem.hidesBackButton = YES;
    BaseView *baseView = [[BaseView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width,  self.view.bounds.size.height)];
    self.tableView.backgroundView = baseView;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.backButton = backButtonItem;
    
    self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects: fixed, self.backButton, nil ];
    

    
    NSLog(@"number of photos for this place %d", [self.feedItem.checkin.place.photos count]);
    NSURLRequest *postcardRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.feedItem.checkin.firstPhoto.url]];
    [self.postCardPhoto setImageWithURLRequest:postcardRequest
                              placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           [self.activityIndicator stopAnimating];
                                       }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"Failure setting postcard image");
                                       }];

    
    [self setStars:[self.feedItem.checkin.place.rating intValue]];
    [self.starsImageView setImage:[self setStars:[self.feedItem.checkin.place.rating intValue]]];
    self.placeAddressLabel.text = self.feedItem.checkin.place.address;
    self.placeTitle.text = self.feedItem.checkin.place.title;
    self.placeTypeImageView.image = [Utils getPlaceTypeImageWithTypeId:[self.feedItem.checkin.place.typeId integerValue]];
    if ([self.feedItem.checkin.place.photos count] > 1) {
        self.postCardPhoto.userInteractionEnabled = YES;
        self.photosScrollView.hidden = NO;
        [self setupScrollView];
    } else {
        self.postCardPhoto.userInteractionEnabled = NO;
        [self.placeShowView setFrame:CGRectMake(self.placeShowView.frame.origin.x, self.placeShowView.frame.origin.y, self.placeShowView.frame.size.width, self.placeShowView.frame.size.height - self.photosScrollView.frame.size.height)];
        self.photosScrollView.hidden = YES;
    }
    
}

- (void)setupFetchedResultsController // attaches an NSFetchRequest to this UITableViewController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Checkin"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"place = %@ and review != nil", self.feedItem.checkin.place];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.feedItem.checkin.place.title;
    [self setupFetchedResultsController];
    [self updateResults];
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
    [self setPlaceShowView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlacePhotosShow"])
    {
        PhotosIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        NSLog(@"number of photos before seque %d", [self.feedItem.checkin.place.photos count]);
        vc.photos = self.feedItem.checkin.place.photos;
    } else if ([[segue identifier] isEqualToString:@"MapShow"]) {
        PlaceMapShowViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
        vc.place = self.feedItem.checkin.place;
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
                NSLog(@"Found a bubble comment, removing.");
                [subview removeFromSuperview];
            }
        }
    }
        
    // Create the comment bubble left
    
    if(indexPath.row == 0) {
        NSLog(@"In cellForRow with row %d and review %@", indexPath.row, checkin.review);
        ReviewBubble *review = [[ReviewBubble alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, 0.0, self.postCardPhoto.frame.size.width, 60.0)];
        [review setReviewText:checkin.review];
        // Set the profile photo
        NSLog(@"User profile photo is %@", checkin.user.remoteProfilePhotoUrl);
        [review setProfilePhotoWithUrl:checkin.user.remoteProfilePhotoUrl];
        [cell addSubview:review];
    } else {
        NSLog(@"In cellForRow with row %d and review %@", indexPath.row, checkin.review);
        UserComment *review = [[UserComment alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, 0.0, self.postCardPhoto.frame.size.width, 60.0)];
        [review setCommentText:checkin.review];
        // Set the profile photo
        NSLog(@"User profile photo is %@", checkin.user.remoteProfilePhotoUrl);
        [review setProfilePhotoWithUrl:checkin.user.remoteProfilePhotoUrl];
        [cell addSubview:review];
    }
    cell.backgroundColor = [UIColor redColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
    if(indexPath.row == 0) {
        // Set the review bubble
        ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, USER_REVIEW_PADDING, self.postCardPhoto.frame.size.width, 60.0)];
        [reviewComment setReviewText:checkin.review];
        NSLog(@"Returning final size of %f", reviewComment.frame.size.height);
        return reviewComment.frame.size.height;
    } else {
        // Set the review bubble
        UserComment *userComment = [[UserComment alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, USER_REVIEW_PADDING, self.postCardPhoto.frame.size.width, 60.0)];
        [userComment setCommentText:checkin.review];
        NSLog(@"Returning final size of %f", userComment.frame.size.height);
        return userComment.frame.size.height;
    }
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
    self.photosScrollView.showsHorizontalScrollIndicator = NO;
    
    int offsetX = 10;
    for (Photo *photo in self.feedItem.checkin.place.photos) {
        PostCardImageView *photoView = [[PostCardImageView alloc] initWithFrame:CGRectMake(offsetX, 0.0, 68.0, 67.0)];
        [photoView setPostcardPhotoWithURL:photo.url];
        photoView.backgroundColor = [UIColor blackColor];
        [self.photosScrollView addSubview:photoView];
        offsetX += 10 + photoView.frame.size.width;
    }
    
    [self.photosScrollView setContentSize:CGSizeMake(offsetX, 68)];
}

- (void)updateResults {
    [RestPlace loadByIdentifier:self.feedItem.checkin.place.externalId onLoad:^(RestPlace *restPlace) {
        [self.feedItem.checkin.place updatePlaceWithRestPlace:restPlace];
    } onError:^(NSString *error) {
        NSLog(@"Problem updating place: %@", error);
    }];
}

@end
