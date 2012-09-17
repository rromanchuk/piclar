//
//  PlaceCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import <UIKit/UIKit.h>
#import "Place.h"
@protocol PlaceCreateDelegate;
@interface PlaceCreateViewController : UITableViewController
@property (weak) id <PlaceCreateDelegate> delegate;
@end


@protocol PlaceCreateDelegate <NSObject>

@required
- (void)didCreatePlace: (Place *)place;
- (void)didCancelPlaceCreation;
@end