//
//  ImageFilterPhobos.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/7/12.
//
//

#import "GPUImageFilterGroup.h"
@class GPUImagePicture;

@interface ImageFilterPhobos : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
@end
