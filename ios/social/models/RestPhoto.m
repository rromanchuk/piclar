

#import "RestPhoto.h"

@implementation RestPhoto
static NSString *RESOURCE = @"api/v1/place/";

@synthesize externalId;
@synthesize title; 
@synthesize url;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"title", @"title",
            @"url", @"url",
            @"externalId", @"id",
            nil];

}

- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nEMAIL: %@\nTITLE: %@\nURL:%@\n",
            self.externalId, self.title, self.url];
}

@end