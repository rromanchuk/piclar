//
//  Photo.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 1/31/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FeedItem, Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;
@property (nonatomic, retain) NSData * largeImage;
@property (nonatomic, retain) NSData * thumbnailImage;
@property (nonatomic, retain) NSString * thumbUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) FeedItem *feedItem;
@property (nonatomic, retain) Place *place;

@end
