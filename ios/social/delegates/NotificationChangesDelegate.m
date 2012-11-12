//
//  NotificationChangesDelegate.m
//  Ostronaut
//
//  Created by Ivan Lazarev on 12.11.12.
//
//

#import "NotificationChangesDelegate.h"

@implementation NotificationChangesDelegate

- (id)initWithObject:(id)object action:(SEL)action {
    self = [super init];
    _object = object;
    _action = action;
    return self;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_object performSelector:_action];
}

@end
