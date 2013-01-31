
@interface UIBarButtonItem (Borderless)
+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action selectedImage:(UIImage *)selectedImage highlightedImage:(UIImage *)highlightedImage;
@end
