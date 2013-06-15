//
//  LeftViewController.h
//  Piclar
//
//  Created by Ryan Romanchuk on 6/12/13.
//
//

typedef enum {
    LeftViewRowTypeFeed,
    LeftViewRowTypeProfile,
    LeftViewRowTypeAboutUs,
    LeftViewRowTypeNotifications,
    numOKPaymentCellRow
} LeftViewRowType;

@protocol LeftViewDelegate;

@interface LeftViewController : UITableViewController
@property (nonatomic, weak) id <LeftViewDelegate> delegate;
@end

@protocol LeftViewDelegate <NSObject>

@required
- (void)doesNeedSegueFor:(NSString *)identifier sender:(id)sender;
@end