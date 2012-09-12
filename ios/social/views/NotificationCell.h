//
//  NotificationCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/12/12.
//
//

#import <UIKit/UIKit.h>
#include "TTTAttributedLabel.h"

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *notificationLabel;

@end
