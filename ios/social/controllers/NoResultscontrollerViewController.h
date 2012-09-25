//
//  NoResultscontrollerViewController.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/24/12.
//
//

#import <UIKit/UIKit.h>
@protocol NoResultsModalDelegate;
@interface NoResultscontrollerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIButton *noResultsCheckinButton;
@property (weak) id <NoResultsModalDelegate> delegate;
- (IBAction)didPressCheckin:(id)sender;

@end

@protocol NoResultsModalDelegate <NSObject>

@required
- (void)userClickedCheckin;

@end