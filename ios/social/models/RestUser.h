@interface RestUser : NSObject
@property (atomic, strong) NSNumber *externalId;
@property (atomic, strong) NSString *token;
@property (atomic, strong) NSString *firstName;
@property (atomic, strong) NSString *lastName;
@property (atomic, strong) NSString *email;
@property (atomic, strong) NSArray *checkins;


- (BOOL)isCurrentUser;
- (BOOL)hasLocation;

- (void)save:(void (^)(RestUser *person))onSuccess
   onFailure:(void (^)(NSString *error))onFailure;

- (void)reload:(void (^)(RestUser *person))onSuccess
     onFailure:(void (^)(NSError *error))onFailure;

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(id object))onLoad
       onError:(void (^)(NSString *error))onError;

+ (void)loadByIdentifier:(NSNumber *)identifer
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSString *error))onError;

+ (void)setCurrentUser:(RestUser *)user;
+ (void)deleteCurrentUser;
+ (RestUser *)currentUser;
+ (NSNumber *)currentUserId;
+ (NSDictionary *)mapping;
@end
