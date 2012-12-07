//
//  NotificationCell.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/12/12.
//
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "ProfilePhotoView.h"
#import "BaseTableViewCell.h"

@interface NotificationCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *notificationLabel;
@property (weak, nonatomic) IBOutlet ProfilePhotoView *profilePhotoView;
@property BOOL isNotRead;
@end
