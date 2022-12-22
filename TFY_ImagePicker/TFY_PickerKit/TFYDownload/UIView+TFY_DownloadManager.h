//
//  UIView+TFY_DownloadManager.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TFYDownloadImageProgressBlock)(CGFloat progress, NSURL *URL);
typedef void(^TFYDownloadImageCompletionBlock)(NSData * data, NSError *error, NSURL *URL);

@interface UIView (TFY_DownloadManager)

- (void)picker_downloadImageWithURL:(NSURL *)url progress:(TFYDownloadImageProgressBlock)progressBlock completed:(TFYDownloadImageCompletionBlock)completedBlock;

- (void)picker_downloadCancel;

- (NSData *)picker_dataFromCacheWithURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
