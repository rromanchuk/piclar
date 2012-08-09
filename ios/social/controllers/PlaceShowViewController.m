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
@synthesize place;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button.png"];
    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    self.backButton = backButtonItem;
    self.navigationItem.leftBarButtonItem = self.backButton;
    Location *location = [Location sharedLocation];
    
    [self.postCardPhoto setImageWithURL:[NSURL URLWithString:self.feedItem.checkin.firstPhoto.url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [self setStars:[self.feedItem.checkin.place.rating intValue]];
    self.placeAddressLabel.text = self.feedItem.checkin.place.address;
    self.placeTitle.text = self.feedItem.checkin.place.title;
    
//    [RestPlace searchByLat:location.latitude
//                    andLon:location.longitude 
//                    onLoad:^(id object) {
//                        NSLog(@"");
//                    } onError:^(NSString *error) {
//                        NSLog(@"");
//                    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = self.feedItem.checkin.place.title;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PlacePhotosShow"])
    {
        PhotosIndexViewController *vc = [segue destinationViewController];
        vc.managedObjectContext = self.managedObjectContext;
                
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

            NSLog(@"PlaceReviewDetailCell");
            NSString *identifier = @"PlaceReviewDetailCell";
            PlaceReviewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlaceReviewDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
}

- (void)setStars:(int)rating {
    self.star1.selected = self.star2.selected = self.star3.selected = self.star4.selected = self.star5.selected = NO;
    switch (rating) {
        case 5:
            self.star1.selected = self.star2.selected = self.star3.selected = self.star4.selected = self.star5.selected = YES;
            break;
        case 4:
            self.star1.selected = self.star2.selected = self.star3.selected = self.star4.selected = YES;
            break;
        case 3:
            self.star1.selected = self.star2.selected = self.star3.selected = YES;
            break;
        case 2:
            self.star1.selected = self.star2.selected = YES;
            break;
        case 1:
            self.star1.selected = YES;
        default:
            break;
    }
}



@end
