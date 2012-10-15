

#import "RestPhoto.h"

@implementation RestPhoto
static NSString *RESOURCE = @"api/v1/photo/";

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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId",  self.title, @"title", self.url, @"url", nil];
    return [dict description];
}

@end
