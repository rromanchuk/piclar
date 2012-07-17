#import "RestCheckin.h"
#import "RestClient.h"
#import "AFJSONRequestOperation.h"

static NSString *RESOURCE = @"api/v1/checkin";

@implementation RestCheckin
@synthesize externalId;
@synthesize createdAt; 
@synthesize updatedAt; 
@synthesize user; 
@synthesize comment;


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"comment", @"comment",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"updatedAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @" modified_date",
            @"createdAt", @"lastname",
            [RestUser mappingWithKey:@"user"
                                        mapping:[RestUser mapping]], @"user",
            nil];
}

+ (void)loadIndexFromRest:(void (^)(id object))onLoad 
                  onError:(void (^)(NSString *error))onError
                 withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    
    NSMutableURLRequest *request = [restClient requestWithMethod:@"POST" path:RESOURCE parameters:[RestClient defaultParameters]];
    NSLog(@"Request is %@", request);
    TFLog(@"CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"%@", JSON);
                                                                                            NSArray *listings = [RestCheckin objectFromJSONObject:JSON mapping:[self mapping]];
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(listings);
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
    return [NSString stringWithFormat:@"[RestCheckin] EXTERNAL_ID: %d\nCREATED AT: %@\nCOMMENT: %@\n",
            self.externalId, self.createdAt, self.comment];
}

@end
