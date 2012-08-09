//
//  PlaceShowViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceShowViewController.h"
#import "PlaceCoverPhotoCell.h"
#import "PlaceMapDetailCell.h"
#import "PlacePhoneDetailCell.h"
#import "PlacePhotosDetailCell.h"
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
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = place.title;
}
- (void)viewDidUnload
{
  
    [self setBackButton:nil];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0) {
        return 165;
    } else if (indexPath.row == 1) {
        return 45; 
    } else if (indexPath.row == 2) {
        return 45;
    } else if (indexPath.row == 3) {
        return 85;
    } else if (indexPath.row == 4) {
        return 90;
    } else if (indexPath.row == 5) {
        return 36;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSLog(@"PlaceCoverPhotoCell");
            NSString *identifier = @"PlaceCoverPhotoCell";
            PlaceCoverPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlaceCoverPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            NSLog(@"PlaceMapDetailCell");
            NSString *identifier = @"PlaceMapDetailCell"; 
            PlaceMapDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlaceMapDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSLog(@"loading cell with %@", place.address);
            cell.addressLabel.text = place.address;
            return cell;
        } else if (indexPath.row == 2) {
            NSLog(@"PlacePhoneDetailCell");
            NSString *identifier = @"PlacePhoneDetailCell";
            PlacePhoneDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlacePhoneDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
        } else if (indexPath.row == 3) {
            NSLog(@"PlacePhotosDetailCell");
            NSString *identifier = @"PlacePhotosDetailCell";
            PlacePhotosDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlacePhotosDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
        } else if (indexPath.row == 4) {
            NSLog(@"PlaceReviewDetailCell");
            NSString *identifier = @"PlaceReviewDetailCell";
            PlaceReviewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlaceReviewDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
        } else if (indexPath.row == 5) {
            NSLog(@"PlaceAllReviewsDetailCell");
            NSString *identifier = @"PlaceAllReviewsDetailCell";
            PlaceAllReviewsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[PlaceAllReviewsDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            return cell;
        }
    } else {
        NSLog(@"IN DIFFERENT SECTION");
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        return cell;
    }
}



@end
