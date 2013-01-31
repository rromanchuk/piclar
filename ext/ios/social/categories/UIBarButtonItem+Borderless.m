#import "UIBarButtonItem+Borderless.h"

@implementation UIBarButtonItem (Borderless)
+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action {
    
    UIButton *gearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gearButton setImage:image forState:UIControlStateNormal]; 
    gearButton.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [gearButton addTarget:target action:action    forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    
    [v addSubview:gearButton];
    
    UIBarButtonItem *customBarButton = [[UIBarButtonItem alloc] initWithCustomView:v];
    return customBarButton;
}

+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action selectedImage:(UIImage *)selectedImage highlightedImage:(UIImage *)highlightedImage {
    
    UIButton *gearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gearButton setImage:image forState:UIControlStateNormal];
    [gearButton setImage:selectedImage forState:UIControlStateSelected];
    [gearButton setImage:highlightedImage forState:UIControlStateHighlighted];
    gearButton.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [gearButton addTarget:target action:action    forControlEvents:UIControlEventTouchUpInside];
    
    UIView *v= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
    
    [v addSubview:gearButton];
    
    UIBarButtonItem *customBarButton = [[UIBarButtonItem alloc] initWithCustomView:v];
    return customBarButton;
}

@end
