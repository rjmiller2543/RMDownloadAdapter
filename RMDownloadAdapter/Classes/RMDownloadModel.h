//
//  RMDownloadModel.h
//  Pods
//
//  Created by Robert Miller on 11/30/16.
//
//

#import <Foundation/Foundation.h>
#import "RMDownloadAdapter.h"

@interface RMDownloadModel : NSObject

/* url and url session to reference start and cancel downloads */
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;

/* we can set the class to be a type to ensure we use the correct ObjC Class when using the data */
@property (nonatomic,copy) NSString *resultClass;

/* index path of corresponding download */
@property (nonatomic,strong) NSIndexPath *indexPath;

/* progress and completion blocks to show a progress HUD and to get the final resulting data and create an object */
@property (nonatomic) RMDownloadAdapterProgressBLock progressBlock;
@property (nonatomic) RMDownloadAdapterCompletionBlock completionBlock;

/* the resulting data from the download task */
@property (nonatomic,strong) NSData *resultData;

@end
