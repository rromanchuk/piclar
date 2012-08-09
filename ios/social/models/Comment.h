//
//  Comment.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 8/9/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) FeedItem *feedItem;
@property (nonatomic, retain) User *user;

@end
