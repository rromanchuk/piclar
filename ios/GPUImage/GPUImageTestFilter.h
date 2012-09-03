#import "GPUImageFilterGroup.h"

@class GPUImagePicture;


@interface GPUImageTestFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}

@end
