//
//  PlaceRatingController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/13/12.
//
//

#import "PlaceRatingController.h"
#import "Place.h"
#import "RestCheckin.h"
@interface PlaceRatingController ()

@end

@implementation PlaceRatingController
@synthesize place;
@synthesize filterdImage;
@synthesize managedObjectContext;

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

- (void)createCheckin {
    [RestCheckin createCheckinWithPlace:self.place.externalId
                                   andPhoto:self.filterdImage
                                 andComment:self.reviewTextField.text
                                  andRating:4
                                     onLoad:^(RestCheckin *checkin) {
                                         NSLog(@"");
                                     }
                                    onError:^(NSString *error) {
                                        NSLog(@"");
                                    }];

}

- (void)viewDidUnload {
    [self setReviewTextField:nil];
    [self setPostcardPhoto:nil];
    [super viewDidUnload];
}
@end
