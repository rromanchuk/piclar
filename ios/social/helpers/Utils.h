
@interface Utils : NSObject
+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (NSString *)MD5:(NSString *)str;
+ (NSDate *)parseDate:(NSString *)date;
+ (CGFloat)sizeForDevice:(CGFloat)size;
+ (UIImage *)getPlaceTypeImageWithTypeId:(int)typeId;
+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;
+ (void)resetCoreData:(NSPersistentStoreCoordinator *)coordinator;
@end
