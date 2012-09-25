//
//  PlaceSearchLoadingCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/7/12.
//
//

#import <UIKit/UIKit.h>

@interface PlaceSearchLoadingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingText;

@end
