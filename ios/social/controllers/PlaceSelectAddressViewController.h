//
//  PlaceSelectAddressViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/20/12.
//
//

#import <UIKit/UIKit.h>
#import "BaseTableView.h"
@protocol SelectAddressDelegate;
@interface PlaceSelectAddressViewController : BaseTableView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *telephoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *zipcodeLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;


@property (weak, nonatomic) NSDictionary *addressDictionary;
@property (weak) id <SelectAddressDelegate> delegate;
- (IBAction)saveAddress:(id)sender;

@end

@protocol SelectAddressDelegate <NSObject>

@required
- (void)didSelectAddress:(NSDictionary *)address;

@end
