//
//  TFY_PhotoPreviewGifCell.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//

#import "TFY_PhotoPreviewGifCell.h"
#import "TFY_PhotoPreviewCell+property.h"
#import "TFY_AssetManager.h"
#import "TFY_GifPlayerManager.h"
#import "TFYCategory.h"

@interface TFY_PhotoPreviewGifCell ()
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;

@property (nonatomic, assign) BOOL waitForReadyToPlay;
@end

@implementation TFY_PhotoPreviewGifCell

- (UIImage *)previewImage
{
    if (self.imageData) {
        return [UIImage picker_imageWithImageData:self.imageData];
    }
    return nil;
}

- (void)setPreviewImage:(UIImage *)previewImage
{
    [super setPreviewImage:previewImage];
    [self.imageView startAnimating];
}

/** 图片大小 */
- (CGSize)subViewImageSize
{
    if (self.imageWidth && self.imageHeight) {
        return CGSizeMake(self.imageWidth, self.imageHeight);
    }
    return self.imageView.image.size;
}

/** 重置视图 */
- (void)subViewReset
{
    [super subViewReset];
    self.imageData = nil;
    [[TFY_GifPlayerManager shared] stopGIFWithKey:[NSString stringWithFormat:@"%zd", [self.model hash]]];
}
/** 设置数据 */
- (void)subViewSetModel:(TFY_PickerAsset *)model completeHandler:(void (^)(id data,NSDictionary *info,BOOL isDegraded))completeHandler progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    if (model.subType == TFYAssetSubMediaTypeGIF) { /** GIF图片处理 */
        // 先获取缩略图
        PHImageRequestID imageRequestID = [[TFY_AssetManager manager] getPhotoWithAsset:model.asset photoWidth:self.bounds.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (completeHandler) {
                completeHandler(photo, info, YES);
            }
        }];
        // 获取原图
        [[TFY_AssetManager manager] getPhotoDataWithAsset:model.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            
            if ([model isEqual:self.model]) {
                
                [[TFY_AssetManager manager] cancelImageRequest:imageRequestID];
                
                if (self.waitForReadyToPlay) {
                    self.waitForReadyToPlay = NO;
                    NSString *modelKey = [NSString stringWithFormat:@"%zd", [self.model hash]];
                    [[TFY_GifPlayerManager shared] transformGifDataToSampBufferRef:data key:modelKey execution:^(CGImageRef imageData, NSString *key) {
                        if ([modelKey isEqualToString:key]) {
                            self.imageView.layer.contents = (__bridge id _Nullable)(imageData);
                        }
                    } fail:^(NSString *key) {
                    }];
                }
                self.imageData = data;
                // gif
                if(data.length > 9) {
                    // gif 6~9 位字符代表尺寸
                    short w1 = 0, w2 = 0;
                    [data getBytes:&w1 range:NSMakeRange(6, 1)];
                    [data getBytes:&w2 range:NSMakeRange(7, 1)];
                    short w = w1 + (w2 << 8);
                    short h1 = 0, h2 = 0;
                    [data getBytes:&h1 range:NSMakeRange(8, 1)];
                    [data getBytes:&h2 range:NSMakeRange(9, 1)];
                    short h = h1 + (h2 << 8);
                    self.imageWidth = w;
                    self.imageHeight = h;
                }
                self.isFinalData = YES;
                /** 这个方式加载GIF内存使用非常高 */
                [self resizeSubviews]; // 刷新subview的位置。
            }
            
        } progressHandler:progressHandler networkAccessAllowed:YES];
    } else {
        [super subViewSetModel:model completeHandler:completeHandler progressHandler:progressHandler];
    }
}

- (void)didDisplayCell
{
    [super didDisplayCell];
    if (self.model.subType == TFYAssetSubMediaTypeGIF) { /** GIF图片处理 */
        if (self.imageData) {
            NSString *modelKey = [NSString stringWithFormat:@"%zd", [self.model hash]];
            if ([[TFY_GifPlayerManager shared] containGIFKey:modelKey]) {
                [[TFY_GifPlayerManager shared] resumeGIFWithKey:modelKey execution:^(CGImageRef imageData, NSString *key) {
                    if ([modelKey isEqualToString:key]) {
                        self.imageView.layer.contents = (__bridge id _Nullable)(imageData);
                    }
                } fail:^(NSString *key) {
                    
                }];
            } else {
                [[TFY_GifPlayerManager shared] transformGifDataToSampBufferRef:self.imageData key:modelKey execution:^(CGImageRef imageData, NSString *key) {
                    if ([modelKey isEqualToString:key]) {
                        self.imageView.layer.contents = (__bridge id _Nullable)(imageData);
                    }
                } fail:^(NSString *key) {
                }];
            }
        } else {
            _waitForReadyToPlay = YES;
        }
    }
}

- (void)willEndDisplayCell
{
    [super willEndDisplayCell];
    if (self.model.subType == TFYAssetSubMediaTypeGIF) { /** GIF图片处理 */
        _waitForReadyToPlay = NO;
        [[TFY_GifPlayerManager shared] suspendGIFWithKey:[NSString stringWithFormat:@"%zd", [self.model hash]]];
    }
}

- (void)didEndDisplayCell
{
    [super didEndDisplayCell];
    if (self.model.subType == TFYAssetSubMediaTypeGIF) { /** GIF图片处理 */
        _waitForReadyToPlay = NO;
        [[TFY_GifPlayerManager shared] stopGIFWithKey:[NSString stringWithFormat:@"%zd", [self.model hash]]];
    }
}


@end
