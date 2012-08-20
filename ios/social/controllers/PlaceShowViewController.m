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
#import "Place.h"
#import "Checkin+Rest.h"
#import "User.h"
#import "Photo.h"
#import "PostCardImageView.h"
#import "ReviewBubble.h"
#import "BaseView.h"
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
@synthesize place;

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

    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
    

    
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
    [self setupScrollView];

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
    NSLog(@"In cellForRow with row %d and review %@", indexPath.row, checkin.review);
    ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, 0.0, self.postCardPhoto.frame.size.width, 60.0)];
    [reviewComment setReviewText:checkin.review];
    // Set the profile photo
    NSLog(@"User profile photo is %@", checkin.user.remoteProfilePhotoUrl);
    [reviewComment setProfilePhotoWithUrl:checkin.user.remoteProfilePhotoUrl];
    [cell addSubview:reviewComment];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Checkin *checkin = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
    
    // Set the review bubble
    ReviewBubble *reviewComment = [[ReviewBubble alloc] initWithFrame:CGRectMake(self.postCardPhoto.frame.origin.x, USER_REVIEW_PADDING, self.postCardPhoto.frame.size.width, 60.0)];
    [reviewComment setReviewText:checkin.review];
    NSLog(@"Returning final size of %f", reviewComment.frame.size.height);
    return reviewComment.frame.size.height;
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
        [photoView setPostcardPhotoWithURL:photo.url];
        photoView.backgroundColor = [UIColor blackColor];
        [self.photosScrollView addSubview:photoView];
        offsetX += 10 + photoView.frame.size.width;
    }
    
    [self.photosScrollView setContentSize:CGSizeMake(offsetX, 68)];
}

@end
