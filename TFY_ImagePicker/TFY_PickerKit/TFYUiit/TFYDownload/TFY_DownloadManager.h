//
//  TFY_DownloadManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^picker_progressBlock)(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL * URL);
typedef void(^picker_completeBlock)(NSData * data, NSError *error, NSURL *URL);

@interface TFY_DownloadInfo : NSObject

@property (nonatomic, assign) NSInteger downloadTimes;
@property (nonatomic, strong) NSURL *downloadURL;

@property (nonatomic, readonly) BOOL reDownload;

@property (nonatomic, copy,nullable) picker_progressBlock progress;
@property (nonatomic, copy,nullable) picker_completeBlock complete;

+ (instancetype)picker_downloadInfoWithURL:(NSURL *)downloadURL;

@end

@interface TFY_DownloadManager : NSObject

+ (TFY_DownloadManager *)shareLFDownloadManager;

/** default YES */
@property (nonatomic, assign) BOOL cacheData;

@property (nonatomic, assign) NSUInteger repeatCountWhenDownloadFailed; // 2
@property (nonatomic, assign) NSInteger maxConcurrentOperationCount; // 5

- (void)picker_requestGetURL:(NSURL *)URL completion:(picker_completeBlock)completion;

- (void)picker_downloadURL:(NSURL *)URL progress:(picker_progressBlock)progress completion:(picker_completeBlock)completion;
- (void)picker_downloadInfo:(TFY_DownloadInfo *)info progress:(picker_progressBlock)progress completion:(picker_completeBlock)completion;
- (void)picker_downloadCancelInfo:(TFY_DownloadInfo *)info;
// 终止下载
- (void)picker_cancelWithURL:(NSURL *)URL;
- (void)picker_cancel;

+ (void)picker_clearCached;

- (NSData *)picker_dataFromSandboxWithURL:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
