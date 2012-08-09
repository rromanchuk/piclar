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
    
    self.title = place.title;
    
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
    self.title = place.title;
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
    return 6;
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



@end
