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
@synthesize feedItemId;
@synthesize placeId;
@synthesize personId;
@synthesize createdAt;
@synthesize user;
@synthesize place;
@synthesize photos;
@synthesize review;

+ (NSDictionary *)mapping {
    return [self mapping:FALSE];
}

+ (NSDictionary *)mapping:(BOOL)is_nested {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"externalId", @"id",
            @"feedItemId", @"feed_item_id",
            @"placeId", @"place_id",
            @"personId", @"person_id",
            @"review", @"review",
            [NSDate mappingWithKey:@"createdAt"
                  dateFormatString:@"yyyy-MM-dd HH:mm:ssZ"], @"create_date",
            [RestUser mappingWithKey:@"user"
                                        mapping:[RestUser mapping]], @"person",

            [RestPhoto mappingWithKey:@"photos" mapping:[RestPhoto mapping]], @"photos",
            @"userRating", @"rate",
            nil];
    if (!is_nested) {
        [map setObject:[RestPlace mappingWithKey:@"place" mapping:[RestPlace mapping:TRUE]] forKey:@"place"];
    }
    return map;
}


+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(UIImage *)photo 
                    andComment:(NSString *)comment
                    andRating:(NSNumber *)rating
              shareOnPlatforms:(NSArray *)platforms
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSError *error))onError;
{
    RestClient *restClient = [RestClient sharedClient];
    NSString *path = [CHEKIN_RESOURCE stringByAppendingString:@".json"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:placeId, @"place_id", rating, @"rate", comment, @"review", nil];
    for (NSString *platform in platforms) {
        [params setValue:@"true" forKey:[NSString stringWithFormat:@"share_%@", platform]];
    }
    NSString *signature = [RestClient signatureWithMethod:@"POST" andParams:params andToken:[RestUser currentUserToken]];
    [params setValue:signature forKey:@"auth"];
    
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.9);
    NSMutableURLRequest *request = [restClient multipartFormRequestWithMethod:@"POST" 
                                                                         path:path 
                                                                   parameters:[RestClient defaultParametersWithParams:params] 
                                                    constructingBodyWithBlock:^(id <AFMultipartFormData>formData) 
                                    {                                     

                                        [formData appendPartWithFileData:imageData 
                                                                    name:@"photo" 
                                                                fileName:@"my_photo.jpg" 
                                                                mimeType:@"image/jpeg"]; 
                                    }]; 
    DLog(@"CHECKIN CREATE REQUEST %@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                            DLog(@"Checkin create JSON: %@", JSON);
                                                                                            RestFeedItem *restFeedItem = [RestFeedItem objectFromJSONObject:JSON mapping:[RestFeedItem mapping]];
                                                                                            
                                                                                            
                                                                                            if (onLoad)
                                                                                                onLoad(restFeedItem);
                                                                                        } 
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                                                                                             NSError *customError = [RestObject customError:error withServerResponse:response andJson:JSON];
                                                                                            if (onError)
                                                                                                onError(customError);
                                                                                        }];
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    [operation start];

                                    
}

- (RestPhoto *)firstPhoto {
    return [self.photos anyObject];
}


- (NSString *) description {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self.externalId], @"externalId",  self.createdAt, @"createdAt", self.review, @"review", self.user, @"user", self.place, @"place", self.photos, @"photos", nil];
    return [dict description];
}

@end
