//
//  SDImageCache+Private.h
//  SDWebImage
//
//  Created by Daniel Muñoz on 20/11/2014.
//  Copyright (c) 2014 Dailymotion. All rights reserved.
//

#import "SDImageCache.h"

@interface SDImageCache (PrivateMethods)

- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSString *)cachedFileNameForKey:(NSString *)key;

@end
