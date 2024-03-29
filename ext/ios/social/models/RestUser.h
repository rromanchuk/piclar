#import "RestObject.h"
@interface RestUser : RestObject

@property NSInteger gender;
@property NSInteger registrationStatus;
@property NSInteger checkinsCount;
@property NSInteger isFollowed;
@property BOOL isNewUserCreated;

// Identifiers
@property (atomic, strong) NSString *authenticationToken;
@property (atomic, strong) NSString *fbToken;
@property (atomic, strong) NSString *vkToken;



@property (atomic, strong) NSString *vkUserId;

// Attributes
@property (atomic, strong) NSString *firstName;
@property (atomic, strong) NSString *lastName;
@property (atomic, strong) NSString *fullName;
@property (atomic, strong) NSString *email;
@property (atomic, strong) UIImage *profilePhoto;
@property (atomic, strong) NSString *remoteProfilePhotoUrl;
@property (atomic, strong) NSString *location;
@property (atomic, strong) NSDate *birthday;
@property (atomic, strong) NSDate *modifiedDate; 


// Associations
@property (atomic, strong) NSArray *checkins;
@property (atomic, strong) NSSet *followers;
@property (atomic, strong) NSSet *following;


+ (void)updateProviderToken:(NSString *)token
                forProvider:(NSString *)provider
                        uid:(NSString *)uid
                     onLoad:(void (^)(RestUser *restUser))onLoad
                    onError:(void (^)(NSError *error))onError;

+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSError *error))onError;


+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestUser *restUser))onLoad
       onError:(void (^)(NSError *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSError *error))onError;

+ (void)loadFeedByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(NSSet *restFeedItems))onLoad
                 onError:(void (^)(NSError *error))onError;

+ (void)loadFollowingInfo:(NSNumber *)externalId
                   onLoad:(void (^)(RestUser *user))onLoad
                  onError:(void (^)(NSError *error))onError;


+ (void)loadSuggested:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSError *error))onError;


+ (NSNumber *)currentUserId;
+ (void)setCurrentUserId:(NSInteger)userId;

+ (NSDictionary *)mapping;
+ (NSDictionary *)mapping:(BOOL)is_nested;

+ (NSString *)currentUserToken;
+ (void)setCurrentUserToken:(NSString *)token;
+ (void)resetIdentifiers;

+ (void)followUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSError *error))onError;

+ (void)unfollowUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSError *error))onError;

- (void)checkCode:(NSString*)code
           onLoad:(void (^)(RestUser *restUser))onLoad
          onError:(void (^)(NSError *error))onError;


- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSError *error))onError;


@end
