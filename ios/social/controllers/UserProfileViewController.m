//
//  UserProfileViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 10/15/12.
//
//

#import "UserProfileViewController.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProfilePhoto:nil];
    [self setNameLabel:nil];
    [self setLocationLabel:nil];
    [self setNumPostcardsLabel:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setCarouselView:nil];
    [super viewDidUnload];
}


#pragma mark - iCarousel delegate methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {

}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
}

@end
