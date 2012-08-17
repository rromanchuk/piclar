#import "RestCheckin.h"
#import "RestClient.h"
#import "RestPhoto.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "RestFeedItem.h"
static NSString *CHEKIN_RESOURCE = @"api/v1/checkin";
static NSString *PERSON_RESOURCE = @"api/v1/person";
static NSString *FEED_RESOURCE = @"api/v1/feed";

@implementation RestCheckin
@synthesize userRating;
@synthesize createdAt; 
@synthesize comment;
@synthesize place;
@synthesize user; 
@synthesize photos;

+ (NSDictionary *)mapping {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"comment", @"comment",
            @"review", @"review",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user"
                                        mapping:[RestUser mapping]], @"person",
            [RestPlace mappingWithKey:@"place" 
                              mapping:[RestPlace mapping]], @"place",
            [RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
            @"userRating", @"rate",
            nil];
}

+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                    andRating:(NSNumber *)rating
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSString *error))onError;
{
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [CHEKIN_RESOURCE stringByAppendingString:@".json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:comment forKey:@"comment"];
    [params setValue:placeId forKey:@"place_id"];
    [params setValue:rating forKey:@"rate"];
    NSLog(@"PARAMS %@", params);

    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
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
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSLog(@"Checkin create JSON: %@", JSON);
                                                                                            RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(restFeedItem);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            NSString *description = [[response allHeaderFields] objectForKey:@"X-Error"];
                                                                                           
                                                                                            NSLog(@"Checkin create error%@", error);
                                                                                            if (onError)
                                                                                                onError(description);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

                                    
}

- (RestPhoto *)firstPhoto {
    return [self.photos anyObject];
}


- (NSString *) description {
    return [NSString stringWithFormat:@"[RestCheckin] EXTERNAL_ID: %d\nCREATED AT: %@\n COMMENT: %@\nUSER: %@\nPLACE: %@\n PHOTOS: %@",
            self.externalId, self.createdAt, self.comment, self.user, self.place, self.photos];
}

@end
