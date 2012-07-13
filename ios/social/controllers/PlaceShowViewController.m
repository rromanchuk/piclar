//
//  PlaceShowViewController.m
//  explorer
//
//  Created by Ryan Romanchuk on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceShowViewController.h"


@interface PlaceShowViewController ()

@end

@implementation PlaceShowViewController
@synthesize placeCoverPhotoCell;
@synthesize mapDetailCell;
@synthesize phonDetailCell;
@synthesize reviewDetailCell;
@synthesize allReviewsCell;
@synthesize photosDetailCell;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setPlaceCoverPhotoCell:nil];
    [self setMapDetailCell:nil];
    [self setPhonDetailCell:nil];
    [self setReviewDetailCell:nil];
    [self setAllReviewsCell:nil];
    [self setPhotosDetailCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    NSLog(@"inside num rows in section");
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier; 
    if(indexPath.row == 0) {
        identifier = @"PlaceCoverPhotoCell";
        PlaceCoverPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[PlaceCoverPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        
        
    } else if (indexPath.row == 1) {
       identifier = @"PlaceCoverPhotoCell"; 
    } else if (indexPath.row == 2) {
        identifier = @"PlaceCoverPhotoCell"; 

    } else if (indexPath.row == 3) {
        identifier = @"PlaceCoverPhotoCell"; 

    } else if (indexPath.row == 4) {
        identifier = @"PlaceCoverPhotoCell"; 

    } else if (indexPath.row == 5) {
        identifier = @"PlaceCoverPhotoCell"; 

    } else if(indexPath.row == 5) {
        
    }
    NSLog(@"IN DEQUEUE");
    static NSString *CellIdentifier = @"CheckinCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}



@end
