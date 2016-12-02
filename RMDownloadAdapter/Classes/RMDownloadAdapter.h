//
//  RMDownloadAdapter.h
//  Pods
//
//  Created by Robert Miller on 11/30/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RMDownloadAdapterErrorCode) {
    RMDownloadAdapterErrorCodeInvalidClass = -1,
    RMDownloadAdapterErrorCodeNoData = -2,
    RMDownloadAdapterErrorCodeUnknown = -3,
};

extern NSString * _Nonnull const RMDownloadAdapterErrorDomain;

/* optional if showing a progress */
typedef void(^RMDownloadAdapterProgressBLock)(float progress);

/* required to get the returned object, if using a standard objective C type, this will return the object, otherwise it will return NSData */
typedef void(^RMDownloadAdapterCompletionBlock)(id object, NSError *error);

@interface RMDownloadAdapter : NSObject

/* start a new download using a url string, progress block to display a HUD, and a completion block to get the resulting data, if we know the class and it's a standard Objective C class, expect a return of the object, if it's a custom class use nil and the returned object type will be NSData in the completion block */
- (void)startDownloadWithURLString:(nonnull NSString  *)urlString withClass:(Class _Nullable )objectClass indexPath:(NSIndexPath * _Nullable)indexPath progressBlock:(RMDownloadAdapterProgressBLock _Nullable)progress completionBlock:(RMDownloadAdapterCompletionBlock _Nonnull)completion;

/* start a new download using an already created url, progress block to display a HUD, and a completion block to get the resulting data, if we know the class and it's a standard Objective C class, use this method and it will return the object rather than the data in the completion block  */
- (void)startDownloadWithURL:(NSURL * _Nonnull)url withClass:(Class _Nullable )objectClass indexPath:(NSIndexPath * _Nonnull)indexPath progressBlock:(RMDownloadAdapterProgressBLock _Nullable)progress completionBlock:(RMDownloadAdapterCompletionBlock _Nonnull)completion;

/* Cancel a download with a url string */
- (void)cancelDownloadAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

/* change the possible cache size, default is 50MB */
- (void)setCacheSizeInMB:(NSUInteger)cacheSize;

/* use the shared instance for a singleton if you plan on sharing the same cache among different controllers, otherwise use [[RMDownloadAdapter alloc] init] */
+ (instancetype _Nonnull)sharedInstance;

@end
