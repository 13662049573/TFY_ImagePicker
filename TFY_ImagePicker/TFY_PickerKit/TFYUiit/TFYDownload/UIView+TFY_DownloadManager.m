//
//  UIView+TFY_DownloadManager.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "UIView+TFY_DownloadManager.h"
#import "TFY_DownloadManager.h"
#import <objc/runtime.h>

static const char * TFYDownloadViewInfoKey = "TFYDownloadViewInfoKey";

@implementation UIView (TFY_DownloadManager)

- (TFY_DownloadInfo *)picker_downloadInfo
{
    return objc_getAssociatedObject(self, TFYDownloadViewInfoKey);
}

- (void)setPicker_downloadInfo:(TFY_DownloadInfo *)picker_downloadInfo
{
    objc_setAssociatedObject(self, TFYDownloadViewInfoKey, picker_downloadInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)picker_downloadImageWithURL:(NSURL *)url progress:(TFYDownloadImageProgressBlock)progressBlock completed:(TFYDownloadImageCompletionBlock)completedBlock
{
    [self picker_downloadCancel];
    
    TFY_DownloadInfo *info = [TFY_DownloadInfo picker_downloadInfoWithURL:url];
    self.picker_downloadInfo = info;
    
    [[TFY_DownloadManager shareLFDownloadManager] picker_downloadInfo:info progress:^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL *downloadURL) {
        if (progressBlock && [self.picker_downloadInfo.downloadURL.absoluteString isEqualToString:downloadURL.absoluteString]) {
            float progress = totalBytesWritten*1.00f/totalBytesExpectedToWrite*1.00f;
            progressBlock(progress, downloadURL);
        }
    } completion:^(NSData *downloadData, NSError *error, NSURL *downloadURL) {
        if (completedBlock && [self.picker_downloadInfo.downloadURL.absoluteString isEqualToString:downloadURL.absoluteString]) {
            self.picker_downloadInfo = nil;
            completedBlock(downloadData, error, downloadURL);
        }
    }];
}

- (void)picker_downloadCancel
{
    [[TFY_DownloadManager shareLFDownloadManager] picker_downloadCancelInfo:self.picker_downloadInfo];
    self.picker_downloadInfo = nil;
}

- (NSData *)picker_dataFromCacheWithURL:(NSURL *)URL
{
    return [[TFY_DownloadManager shareLFDownloadManager] picker_dataFromSandboxWithURL:URL];
}



@end
