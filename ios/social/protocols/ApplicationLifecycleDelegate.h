//
//  ApplicationLifecycleDelegate.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/5/12.
//
//

#import <Foundation/Foundation.h>

@protocol ApplicationLifecycleDelegate <NSObject>
@required
- (void)applicationWillExit;
@end
