//
//  PlaceSelectAddressViewController.m
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/20/12.
//
//

#import "PlaceSelectAddressViewController.h"
#import <AddressBook/ABPerson.h>
@interface PlaceSelectAddressViewController ()

@end

@implementation PlaceSelectAddressViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *backButtonImage = [UIImage imageNamed:@"dismiss.png"];

    UIBarButtonItem *backButtonItem = [UIBarButtonItem barItemWithImage:backButtonImage target:self.navigationController action:@selector(back:)];
    
    [self.saveButton setTitle:NSLocalizedString(@"SAVE", nil)];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: fixed, backButtonItem, nil];
    
    self.title = NSLocalizedString(@"SELECT_ADDRESS_TITLE", @"title for select address");
    
    if (self.addressDictionary) {
        self.streetTextField.text  = [self.addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
        self.stateTextField.text = [self.addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
        self.cityTextField.text = [self.addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
        self.zipcodeTextField.text = [self.addressDictionary objectForKey:(NSString *)kABPersonAddressZIPKey];
        self.telephoneTextField.text = [self.addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
    }
    
    if (self.phone.length) {
        self.telephoneTextField.text = self.phone;
    }
    
    self.stateLabel.text = NSLocalizedString(@"STREET", @"street label");
    self.stateTextField.placeholder = NSLocalizedString(@"STREET_PLACEHOLDER", @"street placeholder");
    
    self.cityLabel.text = NSLocalizedString(@"CITY", nil);
    self.cityTextField.placeholder = NSLocalizedString(@"CITY_PLACEHOLDER", nil);
    
    self.stateLabel.text = NSLocalizedString(@"STATE", nil);
    self.stateTextField.placeholder = NSLocalizedString(@"STATE_PLACEHOLDER", nil);
    
    self.zipcodeLabel.text = NSLocalizedString(@"ZIPCODE", nil);
    self.zipcodeTextField.placeholder = NSLocalizedString(@"ZIPCODE_PLACEHOLDER", nil);
    
    self.telephoneLabel.text = NSLocalizedString(@"TELEPHONE", nil);
    self.telephoneTextField.placeholder = NSLocalizedString(@"TELEPHONE_PLACEHOLDER", nil);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.dele
}

- (void)viewDidUnload {
    [self setCityLabel:nil];
    [self setCityTextField:nil];
    [self setTelephoneLabel:nil];
    [self setTelephoneTextField:nil];
    [self setStateTextField:nil];
    [self setStateLabel:nil];
    [self setZipcodeTextField:nil];
    [self setZipcodeLabel:nil];
    [self setStreetTextField:nil];
    [self setStreetLabel:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.streetTextField) {
        
    } else if (textField == self.cityTextField) {
        
    } else if (textField == self.stateTextField) {
        
    } else if (textField == self.zipcodeTextField) {
        
    } else if (textField == self.telephoneTextField) {
        
    }
}
- (IBAction)saveAddress:(id)sender {
    NSDictionary *addressDict = [NSDictionary dictionaryWithObjectsAndKeys:self.streetTextField.text, kABPersonAddressStreetKey,
                                 self.cityTextField.text, kABPersonAddressCityKey,
                                 self.stateTextField.text, kABPersonAddressStateKey,
                                 self.zipcodeTextField.text, kABPersonAddressZIPKey, nil];
    [self.delegate didSelectAddress:addressDict withPhone:self.telephoneTextField.text];
}
@end
