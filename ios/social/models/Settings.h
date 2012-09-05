//
//  Settings.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/5/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * vkClientId;
@property (nonatomic, retain) NSString * vkScopes;

@end
