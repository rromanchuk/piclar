//
//  PlaceRatingController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/13/12.
//
//
#import "Place.h"
@interface PlaceRatingController : UIViewController
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UIImage *filterdImage;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *reviewTextField;
@property (weak, nonatomic) IBOutlet UIImageView *postcardPhoto;

@end
