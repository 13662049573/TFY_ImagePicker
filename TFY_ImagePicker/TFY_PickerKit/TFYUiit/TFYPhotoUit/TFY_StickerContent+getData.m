//
//  TFY_StickerContent+getData.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_StickerContent+getData.h"
#import "TFY_ConfigTool.h"
#import "TFY_DownloadManager.h"
#import "TFY_PHAssetManager.h"
#import "NSData+picker.h"

@implementation TFY_StickerContent (getData)

- (void)picker_getData:(nullable void(^)(NSData * _Nullable data))completeBlock
{
    if (completeBlock) {
        if (self.state == TFYStickerContentState_Success) {
            switch (self.type) {
                case TFYStickerContentType_PHAsset:
                {
                    [TFY_PHAssetManager picker_GetPhotoDataWithAsset:self.content completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        completeBlock(data);
                    } progressHandler:nil];
                }
            break;
        case TFYStickerContentType_URLForHttp:
        case TFYStickerContentType_URLForFile:
            {
                dispatch_queue_t queue = [TFY_ConfigTool shareInstance].concurrentQueue;
                dispatch_async(queue, ^{
                    NSData *resultData = nil;
                    if (self.type == TFYStickerContentType_URLForHttp) {
                        resultData = [[TFY_DownloadManager shareLFDownloadManager] picker_dataFromSandboxWithURL:self.content];
                    } else if (self.type == TFYStickerContentType_URLForFile) {
                        resultData = [NSData dataWithContentsOfURL:self.content];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completeBlock(resultData);
                    });
                });
            }
            break;
        default:
            {
                completeBlock(nil);
            }
            break;
        }
    } else {
        completeBlock(nil);
    }
    }
}

- (void)picker_getImage:(nullable void(^)(UIImage * _Nullable image, BOOL isDegraded))completeBlock
{
    if (completeBlock) {
        if (self.state == TFYStickerContentState_Success) {
            switch (self.type) {
                case TFYStickerContentType_PHAsset:
                {
                    [TFY_PHAssetManager picker_GetPhotoWithAsset:self.content photoWidth:CGRectGetWidth([UIScreen mainScreen].bounds) completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        completeBlock(result, isDegraded);
                    } progressHandler:nil];
                }
                    break;
                case TFYStickerContentType_URLForHttp:
                case TFYStickerContentType_URLForFile:
                {
                    dispatch_queue_t queue = [TFY_ConfigTool shareInstance].concurrentQueue;
                    dispatch_async(queue, ^{
                        NSData *resultData = nil;
                        if (self.type == TFYStickerContentType_URLForHttp) {
                            resultData = [[TFY_DownloadManager shareLFDownloadManager] picker_dataFromSandboxWithURL:self.content];
                        } else if (self.type == TFYStickerContentType_URLForFile) {
                            resultData = [NSData dataWithContentsOfURL:self.content];
                        }
                        CGFloat maxLine = MAX(CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
                        UIImage *image = [resultData picker_dataDecodedImageWithSize:CGSizeMake(maxLine, maxLine) mode:UIViewContentModeScaleAspectFit];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completeBlock(image, NO);
                        });
                    });
                }
                    break;
                default:
                {
                    completeBlock(nil, NO);
                }
                    break;
            }
        } else {
            completeBlock(nil, NO);
        }
    }

}

- (void)picker_getImageAndData:(nullable void(^)(NSData * _Nullable data, UIImage * _Nullable image))completeBlock
{
    if (!completeBlock) return;
    
    __block NSData *resultData = nil;
    __block UIImage *resultImage = nil;
    
    [self picker_getImage:^(UIImage * _Nullable image, BOOL isDegraded) {
        if (!isDegraded) {
            resultImage = image;
            if (resultImage && resultData) {
                completeBlock(resultData, resultImage);
            }
        }
    }];
    
    [self picker_getData:^(NSData * _Nullable data) {
        resultData = data;
        if (resultImage && resultData) {
            completeBlock(resultData, resultImage);
        }
    }];
}

@end
