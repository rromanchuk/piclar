//
//  ImageFilterMars.h
//  Ostronaut
//
//  Created by Ryan Romanchuk on 9/7/12.
//
//

#import "GPUImageFilterGroup.h"
@class GPUImagePicture;

@interface ImageFilterMars : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
}
@end
