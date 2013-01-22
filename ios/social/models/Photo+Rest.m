//
//  Photo+Rest.m
//  explorer
//
//  Created by Ryan Romanchuk on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo+Rest.h"
#import "RestPhoto.h"
@implementation Photo (Rest)

+ (Photo *)photoWithRestPhoto:(RestPhoto *)restPhoto 
       inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"externalId = %@", [NSNumber numberWithInt:restPhoto.externalId]];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    //request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    
    if (!photos || ([photos count] > 1)) {
        // handle error
    } else if (![photos count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                inManagedObjectContext:context];
        [photo setManagedObjectWithIntermediateObject:restPhoto];
    } else {
        photo = [photos lastObject];
        [photo setManagedObjectWithIntermediateObject:restPhoto];
    }
    
    return photo;

}

- (void)setManagedObjectWithIntermediateObject:(RestObject *)intermediateObject {
    RestPhoto *restPhoto = (RestPhoto *) intermediateObject; 
    self.externalId = [NSNumber numberWithInt:restPhoto.externalId];
    self.url = restPhoto.url;
    self.thumbUrl = restPhoto.thumbUrl;
    self.title = restPhoto.title;
}
@end
