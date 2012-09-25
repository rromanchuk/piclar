//
//  PlaceSelectCategoryViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/17/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseTableView.h"
#import "Place+Rest.h"
@protocol SelectCategoryDelegate;
@interface PlaceSelectCategoryViewController : BaseTableView <SelectCategoryDelegate>

@property (weak, nonatomic) IBOutlet UILabel *hotelLabel;
@property (weak, nonatomic) IBOutlet UILabel *restaurantLabel;
@property (weak, nonatomic) IBOutlet UILabel *attractionLabel;
@property (weak, nonatomic) IBOutlet UILabel *entertainmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *hotelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *restaurantCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *attractionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *entertainmentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mysteryCell;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Place *place;
@property (weak) id <SelectCategoryDelegate> delegate;

@end

@protocol SelectCategoryDelegate <NSObject>

@required
- (void)didSelectCategory:(NSInteger)categoryId;

@end
