//
//  NotificationChangesDelegate.h
//  Ostronaut
//
//  Created by Ivan Lazarev on 12.11.12.
//
//

#import <UIKit/UIKit.h>

@interface NotificationChangesDelegate : NSObject <NSFetchedResultsControllerDelegate>
{
    id _object;
    SEL _action;
}

- (id)initWithObject:(id)object action:(SEL)action;

@end
