//
//  Notification.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/11/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * notificationType;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * createdAt;

@end
