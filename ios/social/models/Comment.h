//
//  Comment.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * externalId;

@end
