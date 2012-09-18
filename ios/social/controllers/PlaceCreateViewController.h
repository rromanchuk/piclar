//
//  PlaceCreateViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "BaseTableView.h"
@protocol PlaceCreateDelegate;
@interface PlaceCreateViewController : BaseTableView

@property (weak) id <PlaceCreateDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickPlaceLabel;
@end


@protocol PlaceCreateDelegate <NSObject>

@required
- (void)didCreatePlace: (Place *)place;
- (void)didCancelPlaceCreation;
@end


