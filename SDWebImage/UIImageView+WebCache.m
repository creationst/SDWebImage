/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIImage+BGColorCalculation.h"
#import "UIImageView+Transition.h"
#import "UIView+WebCacheOperation.h"

static char imageURLKey;

@implementation UIImageView (WebCache)

- (void)sd_setImageWithURL:(NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}


//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
//{
//    [self cancelCurrentImageLoad];
//    
//    if(placeholder != nil)
//        self.image = placeholder;
//    
//    if (url)
//    {
//        __weak UIImageView *wself = self;
//        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
//        {
//            if (!wself) return;
//            dispatch_main_sync_safe(^
//            {
//                __strong UIImageView *sself = wself;
//                if (!sself) return;
//                if (image)
//                {
//                    sself.image = image;
//                    [sself setNeedsLayout];
//                }
//                if (completedBlock && finished)
//                {
//                    completedBlock(image, error, cacheType);
//                }
//            });
//        }];
//        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    }
//}

//old




//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
//{
//    [self cancelCurrentImageLoad];
//    
//    if(placeholder != nil)
//        self.image = placeholder;
//    =======
//    - (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
//        [self sd_cancelCurrentImageLoad];
//        objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        
//        if (!(options & SDWebImageDelayPlaceholder)) {
//            dispatch_main_async_safe(^{
//                self.image = placeholder;
//            });
//        }
//        >>>>>>> upstream/master
//        
//        if (url) {
//            __weak UIImageView *wself = self;
//            <<<<<<< HEAD
//            id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
//                                                 {
//                                                     if (image)
//                                                     {
//                                                         __strong UIImageView *sself = wself;
//                                                         if (!sself) return;
//                                                         if((options & SDWebImageSetComplementaryBGColor) && image.size.width/image.size.height != sself.frame.size.width/sself.frame.size.height)
//                                                         {
//                                                             sself = nil;
//                                                             //We only need to calculate this color if the size of the image is different than the size of frame, eg. we can see the background!
//                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                                                                            {
//                                                                                if (!wself) return;
//                                                                                
//                                                                                //                                    //Calculate color!
//                                                                                //                                    UIColor *backgroundColor = [image calcEdgeColor];//[image calcEdgeColor]
//                                                                                
//                                                                                dispatch_async(dispatch_get_main_queue(), ^
//                                                                                               {
//                                                                                                   __strong UIImageView * _strongSelf = wself;
//                                                                                                   if(!_strongSelf) return;
//                                                                                                   if(options & SDWebImageSetImageWithAnimation){
//                                                                                                       //                                                           [_strongSelf setImage:image withBackGroundColor:backgroundColor withTransitionAnimation:TRUE];
//                                                                                                       [_strongSelf setImage:image withBackGroundColor:[UIColor clearColor] withTransitionAnimation:TRUE];
//                                                                                                   }
//                                                                                                   else{
//                                                                                                       //                                                           _strongSelf.backgroundColor = backgroundColor;
//                                                                                                       _strongSelf.image = image;
//                                                                                                       [_strongSelf setNeedsLayout];
//                                                                                                   }
//                                                                                                   if (completedBlock && finished)
//                                                                                                   {
//                                                                                                       completedBlock(image, error, cacheType);
//                                                                                                   }
//                                                                                                   _strongSelf = nil;
//                                                                                               });
//                                                                            });
//                                                         }
//                                                         else
//                                                         {
//                                                             if(!wself) return;
//                                                             dispatch_main_sync_safe(^
//                                                                                     {
//                                                                                         __strong UIImageView *strongself = wself;
//                                                                                         if (!strongself) return;
//                                                                                         
//                                                                                         if(options & SDWebImageSetImageWithAnimation)
//                                                                                             [strongself setImage:image withTransitionAnimation:TRUE];
//                                                                                         else
//                                                                                             strongself.image = image;
//                                                                                         [strongself setNeedsLayout];
//                                                                                         if (completedBlock && finished)
//                                                                                         {
//                                                                                             completedBlock(image, error, cacheType);
//                                                                                         }
//                                                                                     });
//                                                             =======
//                                                             id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                                                 if (!wself) return;
//                                                                 dispatch_main_sync_safe(^{
//                                                                     if (!wself) return;
//                                                                     if (image) {
//                                                                         wself.image = image;
//                                                                         [wself setNeedsLayout];
//                                                                     } else {
//                                                                         if ((options & SDWebImageDelayPlaceholder)) {
//                                                                             wself.image = placeholder;
//                                                                             [wself setNeedsLayout];
//                                                                         }
//                                                                     }
//                                                                     if (completedBlock && finished) {
//                                                                         completedBlock(image, error, cacheType, url);
//                                                                         >>>>>>> upstream/master
//                                                                     }
//                                                                 }
//                                                                                         else
//                                                                                         {
//                                                                                             NSError *errorNotFound = [NSError errorWithDomain:@"Not found" code:0 userInfo:nil];
//                                                                                             if (completedBlock)
//                                                                                                 completedBlock(nil, errorNotFound, SDImageCacheTypeNone);
//                                                                                         }
//                                                                                         
//                                                                                         }];
//                                                                                         [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
//                                                                                         } else {
//                                                                                             dispatch_main_async_safe(^{
//                                                                                                 NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
//                                                                                                 if (completedBlock) {
//                                                                                                     completedBlock(nil, error, SDImageCacheTypeNone, url);
//                                                                                                 }
//                                                                                             });
//                                                                                         }
//                                                                                         }








- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak UIImageView *wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    if(options & SDWebImageSetImageWithAnimation)
                        [wself setImage:image withTransitionAnimation:YES];
                    else
                        wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}


- (void)sd_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self sd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];    
}

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)sd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self sd_cancelCurrentAnimationImagesLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self sd_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)sd_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)sd_cancelCurrentAnimationImagesLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}

@end
