//
//  RMDownloadCache.h
//  Pods
//
//  Created by Robert Miller on 12/1/16.
//
//

#import <Foundation/Foundation.h>
#import "RMDownloadModel.h"

@interface RMDownloadCache : NSCache

/* add an object to the cache */
- (void)addObjectToCache:(RMDownloadModel *)object;

/* when we know the size of the object to be cached, we alert the cache of the size so we know to evict */
- (void)addCacheSizeToCache:(NSUInteger)cacheSize;

/* set the cache size in MB default is 50MB */
- (void)setTotalCacheSize:(NSUInteger)cacheSize;

@end
