

#import "RestPlace.h"
#import "AFJSONRequestOperation.h"
#import "RestClient.h"

@implementation RestPlace

static NSString *RESOURCE = @"api/v1/place";
@synthesize externalId;
@synthesize title; 
@synthesize desc;
@synthesize address;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize reviews;
@synthesize photos;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"title", @"title",
            @"desc", @"description",
            @"address", @"address",
            @"externalId", @"id",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"updatedAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"modified_date",
            nil];
}

+ (void)loadByIdentifier:(NSInteger)identifier
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *error))onError {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [RESOURCE stringByAppendingString:[NSString stringWithFormat:@"/%d.json", identifier]];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParameters]];
    NSLog(@"Request is %@", request);
    TFLog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
                                                                                            RestPlace *place = [RestPlace objectFromJSONObject:JSON mapping:[RestPlace mapping]];
                                                                                            if (onLoad)
                                                                                                onLoad(place);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSLog(@"%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

}


- (NSString *) description {
    return [NSString stringWithFormat:@"EXTERNAL_ID: %d\nTITLE: %@\nDESCRIPTION: %@\nADDRESS:",
            self.externalId, self.title, self.desc, self.address];
}
@end
