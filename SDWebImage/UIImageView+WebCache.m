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

static char operationKey;
static char operationArrayKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
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
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self cancelCurrentImageLoad];
    
    if(placeholder != nil)
        self.image = placeholder;
    
    if (url)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            if (image)
            {
                __strong UIImageView *sself = wself;
                if (!sself) return;
                if((options & SDWebImageSetComplementaryBGColor) && image.size.width/image.size.height != sself.frame.size.width/sself.frame.size.height)
                {
                    sself = nil;
                    //We only need to calculate this color if the size of the image is different than the size of frame, eg. we can see the background!
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                                {
                                    if (!wself) return;
                                    
//                                    //Calculate color!
//                                    UIColor *backgroundColor = [image calcEdgeColor];//[image calcEdgeColor]
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       __strong UIImageView * _strongSelf = wself;
                                                       if(!_strongSelf) return;
                                                       if(options & SDWebImageSetImageWithAnimation){
//                                                           [_strongSelf setImage:image withBackGroundColor:backgroundColor withTransitionAnimation:TRUE];
                                                           [_strongSelf setImage:image withBackGroundColor:[UIColor clearColor] withTransitionAnimation:TRUE];
                                                       }
                                                       else{
//                                                           _strongSelf.backgroundColor = backgroundColor;
                                                           _strongSelf.image = image;
                                                           [_strongSelf setNeedsLayout];
                                                       }
                                                       if (completedBlock && finished)
                                                       {
                                                           completedBlock(image, error, cacheType);
                                                       }
                                                       _strongSelf = nil;
                                                   });
                                });
                }
                else
                {
                    if(!wself) return;
                    dispatch_main_sync_safe(^
                    {
                        __strong UIImageView *strongself = wself;
                        if (!strongself) return;
                        
                        if(options & SDWebImageSetImageWithAnimation)
                            [strongself setImage:image withTransitionAnimation:TRUE];
                        else
                            strongself.image = image;
                        [strongself setNeedsLayout];
                        if (completedBlock && finished)
                        {
                            completedBlock(image, error, cacheType);
                        }
                    });
                }
            }
            else
            {
                NSError *errorNotFound = [NSError errorWithDomain:@"Not found" code:0 userInfo:nil];
                if (completedBlock)
                    completedBlock(nil, errorNotFound, SDImageCacheTypeNone);
            }
            
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}



- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs
{
    [self cancelCurrentArrayLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs)
    {
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            if (!wself) return;
            dispatch_main_sync_safe(^
            {
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image)
                {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages)
                    {
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

    objc_setAssociatedObject(self, &operationArrayKey, [NSArray arrayWithArray:operationsArray], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentArrayLoad
{
    // Cancel in progress downloader from queue
    NSArray *operations = objc_getAssociatedObject(self, &operationArrayKey);
    for (id<SDWebImageOperation> operation in operations)
    {
        if (operation)
        {
            [operation cancel];
        }
    }
    objc_setAssociatedObject(self, &operationArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
