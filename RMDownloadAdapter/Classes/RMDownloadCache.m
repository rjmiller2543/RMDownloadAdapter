//
//  RMDownloadCache.m
//  Pods
//
//  Created by Robert Miller on 12/1/16.
//
//

#import "RMDownloadCache.h"

@interface RMDownloadCache ()

@property(nonatomic) NSUInteger totalCacheSize;
@property(nonatomic) NSUInteger currentCacheSize;
@property(nonatomic,strong) NSMutableArray *objectReferenceInCache;

@end

@implementation RMDownloadCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentCacheSize = 0;
        _objectReferenceInCache = [[NSMutableArray alloc] init];
        _totalCacheSize = 50000000; //Default is 50MB
    }
    
    return self;
}

- (void)addObjectToCache:(RMDownloadModel *)object
{
    //check if the object is already in cache
    RMDownloadModel *downloadObjectInCache = [self objectForKey:object.url.absoluteString];
    if (downloadObjectInCache != nil) {
        
        NSUInteger indexOfURLToBeMoved = [self.objectReferenceInCache indexOfObject:downloadObjectInCache.url.absoluteString];
        NSString *urlToBeMoved = [self.objectReferenceInCache objectAtIndex:indexOfURLToBeMoved];
        [self.objectReferenceInCache removeObjectAtIndex:indexOfURLToBeMoved];
        [self.objectReferenceInCache insertObject:urlToBeMoved atIndex:0];
        
    } else {
        
        [self.objectReferenceInCache insertObject:object.url.absoluteString atIndex:0];
        [self setObject:object forKey:object.url.absoluteString];
        [self addCacheSizeToCache:object.resultData.length];
        
    }
}

- (void)addCacheSizeToCache:(NSUInteger)cacheSize
{
    //add the cache size to the current cache size
    self.currentCacheSize += cacheSize;
    
    //if the current cache size is over the total cache size get the last url from array and evict/remove from cache
    if (self.currentCacheSize >= self.totalCacheSize) {
        NSString *urlForEviction = [self.objectReferenceInCache lastObject];
        RMDownloadModel *downloadModelForEviction = [self objectForKey:urlForEviction];
        
        self.currentCacheSize -= downloadModelForEviction.resultData.length;
        [self removeObjectForKey:urlForEviction];
        [self addCacheSizeToCache:0];
    }
}

- (void)setTotalCacheSize:(NSUInteger)cacheSize
{
    _totalCacheSize = cacheSize;
}

@end
