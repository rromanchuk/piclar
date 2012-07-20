#import "RestCheckin.h"
#import "RestClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

static NSString *CHEKIN_RESOURCE = @"api/v1/checkin";
static NSString *PERSON_RESOURCE = @"api/v1/person";

@implementation RestCheckin
@synthesize externalId;
@synthesize createdAt; 
@synthesize updatedAt; 
@synthesize user; 
@synthesize comment;


+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"comment", @"comment",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"create_date",
            [NSDate mappingWithKey:@"updatedAt"
                  dateFormatString:@"yyyy-MM-dd'T'hh:mm:ssZ"], @"modified_date",
            [RestUser mappingWithKey:@"user"
                                        mapping:[RestUser mapping]], @"user",
            nil];
}

+ (void)loadIndex:(void (^)(id object))onLoad 
                  onError:(void (^)(NSString *error))onError
                 withPage:(int)page {
    
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [PERSON_RESOURCE stringByAppendingString:@"/logged/feed.json"];
    NSMutableURLRequest *request = [restClient requestWithMethod:@"GET" path:path parameters:[RestClient defaultParameters]];
    NSLog(@"CHECKIN INDEX REQUEST %@", request);
    TFLog(@"CHECKIN INDEX REQUEST: %@", request);
    
    

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON %@", JSON);
                                                                                            if ([JSON count] > 0) {
//                                                                                                id objects = [JSON objectForKey:@"objects"];
//                                                                                                NSLog(@"objects %@", objects);
//                                                                                                //                                                                                                NSLog(@"class %@", NSStringFromClass([JSON class]) );
//                                                                                                NSLog(@"listings %@", listings);
//                                                                                                if (onLoad)
//                                                                                                    onLoad(listings);
                                                                                            }
                                                                                            
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

+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                        onLoad:(void (^)(id object))onLoad
                       onError:(void (^)(NSString *error))onError;
{
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [CHEKIN_RESOURCE stringByAppendingString:@".json"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:placeId, @"place_id", comment, @"comment", nil];
    NSData *imageData = UIImagePNGRepresentation(photo);
    
    NSMutableURLRequest *request = [restClient multipartFormRequestWithMethod:@"POST" 
                                                                         path:path 
                                                                   parameters:[RestClient defaultParametersWithParams:params] 
                                                    constructingBodyWithBlock:^(id <AFMultipartFormData>formData) 
                                    {                                     

                                        [formData appendPartWithFileData:imageData 
                                                                    name:@"photo" 
                                                                fileName:@"my_photo.png" 
                                                                mimeType:@"image/png"]; 
                                    }]; 
    NSLog(@"CHECKIN CREATE REQUEST %@", request);
    TFLog(@"CHECKIN CREATE REQUEST: %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"JSON: %@", JSON);
                                                                                            NSArray *checkin = [RestCheckin objectFromJSONObject:JSON mapping:[self mapping]];
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(checkin);
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
    return [NSString stringWithFormat:@"[RestCheckin] EXTERNAL_ID: %d\nCREATED AT: %@\n MODIFIED AT: %@\nCOMMENT: %@\n",
            self.externalId, self.createdAt, self.updatedAt, self.comment];
}

@end
