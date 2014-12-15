//
//  UIImage+MultiFormat.m
//  SDWebImage
//
//  Created by Olivier Poitrey on 07/06/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"

#ifdef SD_WEBP
#import "UIImage+WebP.h"
#endif

@implementation UIImage (MultiFormat)

+ (UIImage *)sd_imageWithData:(NSData *)data
{
    UIImage *image;
    
    if ([data sd_isGIF])
    {
        if ([UIImage respondsToSelector:@selector(sd_animatedGIFWithData:)])
            image = [UIImage sd_animatedGIFWithData:data];
    }
    else
    {
        image = [[UIImage alloc] initWithData:data];
    }

#ifdef SD_WEBP
    if (!image && [UIImage respondsToSelector:@selector(sd_imageWithWebPData:)]) // TODO: detect webp signature
    {
        if ([UIImage respondsToSelector:@selector(sd_imageWithWebPData:)])
            image = [UIImage sd_imageWithWebPData:data];
    }
#endif

    return image;
}

@end
