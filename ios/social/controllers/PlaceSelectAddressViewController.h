//
//  PlaceSelectAddressViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/20/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseTableView.h"
@interface PlaceSelectAddressViewController : BaseTableView
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *telephoneTextField;

@property (weak, nonatomic) NSDictionary *addressDictionary;

@end
