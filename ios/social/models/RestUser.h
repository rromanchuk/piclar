#import "RestObject.h"
@interface RestUser : RestObject
@property NSInteger gender;
@property NSInteger registrationStatus;
@property NSInteger checkinsCount;
@property NSInteger isFollowed;
@property BOOL isNewUserCreated;

// Identifiers
@property (atomic, strong) NSString *token;
@property (atomic, strong) NSString *vkontakteToken;
@property (atomic, strong) NSString *facebookToken;

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




- (BOOL)isCurrentUser __deprecated;

- (void)update;

+ (void)updateProviderToken:(NSString *)token
                forProvider:(NSString *)provider
                     onLoad:(void (^)(RestUser *restUser))onLoad
                    onError:(void (^)(NSString *error))onError;

+ (void)reload:(void (^)(RestUser *person))onLoad
     onError:(void (^)(NSError *error))onError;

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(RestUser *restUser))onLoad
       onError:(void (^)(NSError *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(RestUser *restUser))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)loadFeedByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(NSSet *restFeedItems))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)loadFollowers:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError;

+ (void)loadFollowing:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError;

- (void)loadFollowing:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError;

+ (void)loadSuggested:(NSNumber *)externalId
               onLoad:(void (^)(NSSet *users))onLoad
              onError:(void (^)(NSString *error))onError;

+ (void)setCurrentUser:(RestUser *)user __deprecated;
+ (void)deleteCurrentUser __deprecated;
+ (RestUser *)currentUser __deprecated;
+ (NSNumber *)currentUserId;
+ (void)setCurrentUserId:(NSInteger)userId;
+ (NSDictionary *)mapping;
+ (NSString *)currentUserToken;
+ (void)setCurrentUserToken:(NSString *)token;
+ (void)resetIdentifiers;

+ (void)followUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSString *error))onError;

+ (void)unfollowUser:(NSNumber *)externalId
            onLoad:(void (^)(RestUser *restUser))onLoad
           onError:(void (^)(NSString *error))onError;

- (void)checkCode:(NSString*)code
           onLoad:(void (^)(RestUser *restUser))onLoad
          onError:(void (^)(NSString* error))onError;


- (void)pushToServer:(void (^)(RestUser *restUser))onLoad
             onError:(void (^)(NSString *error))onError;


@end
