//
//  Photo+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "RESTable.h"
#import "RestPhoto.h"
@interface Photo (Rest) <RESTable>

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject;

+ (Photo *)photoWithRestPhoto:(RestPhoto *)restPhoto 
             inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSManagedObject *)findOrCreateWithNetworkIfNeeded:(NSNumber *)identifier
                              inManagedObjectContext:(NSManagedObjectContext *)context;

@end
