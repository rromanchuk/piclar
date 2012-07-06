#import "ExplorerObject.h"

@interface User : ExplorerObject

@property (atomic, assign) NSInteger identifier; 
@property (atomic, retain) NSString *username;
@property (atomic, retain) NSString *first_name;
@property (atomic, retain) NSString *last_name;
@property (atomic, retain) NSString *email;

- (BOOL)isCurrentUser;
- (BOOL)hasLocation;

- (void)save:(void (^)(User *person))onSuccess
   onFailure:(void (^)(NSString *error))onFailure;

- (void)reload:(void (^)(User *person))onSuccess
     onFailure:(void (^)(NSError *error))onFailure;

+ (void)loginUserWithEmail:(NSString *)email
                  password:(NSString *)password
                    onLoad:(void (^)(id object))onLoad
                   onError:(void (^)(NSString *error))onError;

+ (void)create:(NSMutableDictionary *)parameters
        onLoad:(void (^)(id object))onLoad
       onError:(void (^)(NSString *error))onError;

+ (void)loadByIdentifier:(NSInteger)userId
                  onLoad:(void (^)(id object))onLoad
                 onError:(void (^)(NSError *error))onError;

+ (void)setCurrentUser:(User *)user;
+ (void)deleteCurrentUser;
+ (User *)currentUser;
+ (int)currentUserId;

@end
