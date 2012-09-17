//
//  PlaceSelectCategoryViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/17/12.
//
//

#import <UIKit/UIKit.h>

@interface PlaceSelectCategoryViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *hotelLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UILabel *attractionLabel;
@property (weak, nonatomic) IBOutlet UILabel *entertainmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;

@end
