
#import "RestObject.h"
#import "RestUser.h"
#import "RestPlace.h"
#import "RestPhoto.h"
#import "RestComment.h"
#import "Location.h"

@interface RestCheckin : RestObject
@property NSInteger userRating;
@property NSInteger feedItemId;
@property NSInteger placeId;
@property NSInteger personId;


@property (atomic, strong) NSDate *createdAt; 
@property (atomic, strong) RestUser *user;
@property (atomic, strong) RestPlace *place;
@property (atomic, strong) NSSet *photos;
@property (atomic, strong) NSString *review;

+ (NSDictionary *)mapping;
+ (NSDictionary *)mapping:(BOOL)is_nested;

            
+ (void)createCheckinWithPlace:(NSNumber *)placeId 
                      andPhoto:(NSMutableData *)photo
                    andComment:(NSString *)comment
                     andRating:(NSNumber *)rating
              shareOnPlatforms:(NSArray *)platforms
                        onLoad:(void (^)(id feedItem))onLoad
                       onError:(void (^)(NSError *error))onError;

@end
