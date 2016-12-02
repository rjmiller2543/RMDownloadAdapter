//
//  RMDownloadAdapter.m
//  Pods
//
//  Created by Robert Miller on 11/30/16.
//
//

#import "RMDownloadAdapter.h"
#import "RMDownloadCache.h"

NSString *const RMDownloadAdapterErrorDomain = @"RMDownloadAdapterErrorDomain";

@interface RMDownloadAdapter () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic,strong) RMDownloadCache *downloadAdapterCache;
@property (nonatomic,strong) NSURLSession *downloadAdapterSession;

@property (nonatomic,strong) NSMutableArray *concurrentDownloads;

@end

@implementation RMDownloadAdapter

+ (instancetype)sharedInstance
{
    static RMDownloadAdapter *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RMDownloadAdapter alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadAdapterCache = [[RMDownloadCache alloc] init];
        [_downloadAdapterCache setTotalCacheSize:50000000]; //set the total cost limit to the default 50MB
        
        _concurrentDownloads = [[NSMutableArray alloc] init];
        
        _downloadAdapterSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)setCacheSizeInMB:(NSUInteger)cacheSize
{
    [self.downloadAdapterCache setTotalCacheSize:cacheSize];
}

#pragma mark - Download Methods
- (void)startDownloadWithURLString:(NSString *)urlString withClass:(__unsafe_unretained Class _Nullable)objectClass indexPath:(NSIndexPath *)indexPath progressBlock:(RMDownloadAdapterProgressBLock)progress completionBlock:(RMDownloadAdapterCompletionBlock)completion
{
    RMDownloadModel *downloadModel = [self.downloadAdapterCache objectForKey:urlString];
    
    if (downloadModel != nil) {
        
        [self.downloadAdapterCache addObjectToCache:downloadModel];
        if (downloadModel.resultClass != nil) {
            
            @try {
                id object = [[NSClassFromString(downloadModel.resultClass) alloc] initWithData:downloadModel.resultData];
                completion(object, nil);
            } @catch (NSException *exception) {
                NSError *error = [NSError errorWithDomain:RMDownloadAdapterErrorDomain code:RMDownloadAdapterErrorCodeInvalidClass userInfo:nil];
                completion(downloadModel.resultData, error);
            } @finally {
                
            }
            
        } else {
            completion(downloadModel.resultData, nil);
        }
        
        return;
        
    }  else {
        
        downloadModel = [self downloadModelWithURL:[NSURL URLWithString:urlString] withClass:objectClass progressBlock:progress completionBlock:completion];
        downloadModel.indexPath = indexPath;
        
        [self.concurrentDownloads addObject:downloadModel];
        
    }
    
    [downloadModel.downloadTask resume];
}

- (void)startDownloadWithURL:(NSURL *)url withClass:(__unsafe_unretained Class _Nullable)objectClass indexPath:(NSIndexPath *)indexPath progressBlock:(RMDownloadAdapterProgressBLock)progress completionBlock:(RMDownloadAdapterCompletionBlock)completion
{
    RMDownloadModel *downloadModel = [self.downloadAdapterCache objectForKey:url.absoluteString];
    
    if (downloadModel != nil) {
        
        [self.downloadAdapterCache addObjectToCache:downloadModel];
        if (downloadModel.resultClass != nil) {
            
            @try {
                id object = [[NSClassFromString(downloadModel.resultClass) alloc] initWithData:downloadModel.resultData];
                completion(object, nil);
            } @catch (NSException *exception) {
                NSError *error = [NSError errorWithDomain:RMDownloadAdapterErrorDomain code:RMDownloadAdapterErrorCodeInvalidClass userInfo:nil];
                completion(downloadModel.resultData, error);
            } @finally {
                
            }
            
        } else {
            completion(downloadModel.resultData, nil);
        }
        
        return;
        
    } else {
        
        downloadModel = [self downloadModelWithURL:url withClass:objectClass progressBlock:progress completionBlock:completion];
        downloadModel.indexPath = indexPath;
        
        [self.concurrentDownloads addObject:downloadModel];
        
    }
    
    [downloadModel.downloadTask resume];
}

- (RMDownloadModel *)downloadModelWithURL:(NSURL *)url withClass:(__unsafe_unretained Class _Nullable)objectClasss progressBlock:(RMDownloadAdapterProgressBLock)progress completionBlock:(RMDownloadAdapterCompletionBlock)completion
{
    RMDownloadModel *downloadModel = [[RMDownloadModel alloc] init];
    
    if (objectClasss != nil) {
        downloadModel.resultClass = NSStringFromClass(objectClasss);
    }
    
    downloadModel.url = url;
    downloadModel.progressBlock = progress;
    downloadModel.completionBlock = completion;
    
    NSURLSessionDownloadTask *downloadTask = [self.downloadAdapterSession downloadTaskWithURL:downloadModel.url];
    downloadTask.taskDescription = url.absoluteString;
    downloadModel.downloadTask = downloadTask;
    
    return downloadModel;
}

- (void)cancelDownloadAtIndexPath:(NSIndexPath *)indexPath
{
    __block RMDownloadModel *downloadModel = nil;
    [self.concurrentDownloads enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RMDownloadModel *objModel = (RMDownloadModel *)obj;
        if ([objModel.indexPath isEqual:indexPath]) {
            downloadModel = objModel;
            *stop = YES;
        }
    }];
    
    [downloadModel.downloadTask cancel];
    [self.concurrentDownloads removeObject:downloadModel];
}


#pragma mark - NSURLSessionDelegate Methods
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSString *urlForSession = task.taskDescription;
    
    NSArray *arrayOfDownloadModelsWithURL = [self.concurrentDownloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.url.absoluteString = %@", urlForSession]];
    
    for (RMDownloadModel *downloadModel in arrayOfDownloadModelsWithURL) {
        if (error != nil && error.code != -999) {
            downloadModel.completionBlock(nil, error);
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *urlForSession = downloadTask.taskDescription;
    
    NSArray *arrayOfDownloadModelsWithURL = [self.concurrentDownloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.url.absoluteString = %@", urlForSession]];
    
    RMDownloadModel *downloadModelForCache = nil;
    for (RMDownloadModel *downloadModel in arrayOfDownloadModelsWithURL) {
        
        NSData *resultData = [NSData dataWithContentsOfURL:location];
        downloadModel.resultData = resultData;
        
        if (downloadModel.resultClass != nil) {
            
            @try {
                id object = [[NSClassFromString(downloadModel.resultClass) alloc] initWithData:downloadModel.resultData];
                downloadModel.completionBlock(object, nil);
            } @catch (NSException *exception) {
                NSError *error = [NSError errorWithDomain:RMDownloadAdapterErrorDomain code:RMDownloadAdapterErrorCodeInvalidClass userInfo:nil];
                downloadModel.completionBlock(downloadModel.resultData, error);
            } @finally {
                
            }
            
        } else {
            downloadModel.completionBlock(downloadModel.resultData, nil);
        }
        downloadModelForCache = downloadModel;
    }
    [self.downloadAdapterCache addObjectToCache:downloadModelForCache];
    [self.concurrentDownloads removeObjectsInArray:arrayOfDownloadModelsWithURL];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *urlForSession = downloadTask.taskDescription;
    
    NSArray *arrayOfDownloadModelsWithURL = [self.concurrentDownloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.url.absoluteString = %@", urlForSession]];
    
    for (RMDownloadModel *downloadModel in arrayOfDownloadModelsWithURL) {
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        if (downloadModel.progressBlock != nil) {
            downloadModel.progressBlock(progress);
        }
    }
}

@end
