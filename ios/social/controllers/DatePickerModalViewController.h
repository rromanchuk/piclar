//
//  DatePickerModalViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/17/12.
//
//

#import <UIKit/UIKit.h>
@protocol DatePickerModalDelegate;

@interface DatePickerModalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id <DatePickerModalDelegate> deleegate;
@end

@protocol DatePickerModalDelegate <NSObject>

@required
- (IBAction)didSelectDate:(id)sender;

@end