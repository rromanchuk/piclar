//
//  NSNull+Helper.h
//  Piclar
//
//  Created by Ryan Romanchuk on 2/25/13.
//
//

#import <Foundation/Foundation.h>

@interface NSNull (Helper)
// This method makes it easier when inserting objects into a dictionary, prevents "attempt to insert nil" fatals.
//  NSDictionary *dict = @{"riskyObject": [NSNull nullWhenNil:myObject]};
+ (id)nullWhenNil:(id)obj;
@end
