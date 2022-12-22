//
//  UIImage+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYImageType) {
    TFYImageType_Unknow = 0,
    TFYImageType_JPEG,
    TFYImageType_JPEG2000,
    TFYImageType_TIFF,
    TFYImageType_BMP,
    TFYImageType_ICO,
    TFYImageType_ICNS,
    TFYImageType_GIF,
    TFYImageType_PNG,
    TFYImageType_WebP,
};

CG_EXTERN TFYImageType TFYImageDetectType(CFDataRef data);

@interface UIImage (picker)

/** 修正图片方向 */
- (UIImage *)picker_fixOrientation;

/** 图片正方向的修正参数 */
+ (CGAffineTransform)picker_exchangeOrientation:(UIImageOrientation)imageOrientation size:(CGSize)size;

/** 计算图片的缩放大小 */
+ (CGSize)picker_scaleImageSizeBySize:(CGSize)imageSize targetSize:(CGSize)size isBoth:(BOOL)isBoth;

/** 缩放图片到指定大小 */
- (UIImage*)picker_scaleToFitSize:(CGSize)size;
/** 缩放图片到指定大小 */
- (UIImage*)picker_scaleToFillSize:(CGSize)size;

/** 截取部分图像 */
- (UIImage *)picker_cropInRect:(CGRect)rect;

/** 合并图片（图片大小一致） */
- (UIImage *)picker_mergeimages:(NSArray <UIImage *>*)images;
/** 合并图片(图片大小以第一张为准) */
+ (UIImage *)picker_mergeimages:(NSArray <UIImage *>*)images;

/** 将图片旋转弧度radians */
- (UIImage *)picker_imageRotatedByRadians:(CGFloat)radians;

/** 提取图片上的颜色 */
- (UIColor *)picker_colorAtPixel:(CGPoint)point;
/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)picker_transToMosaicLevel:(NSUInteger)level;

/** 高斯模糊 */
- (UIImage *)picker_transToBlurLevel:(NSUInteger)blurRadius;

- (UIImage *)picker_tipGuideViewMaskImage:(UIColor *)maskColor;

/** 快速压缩 压缩到大约指定体积大小(kb) 返回压缩后图片 */
- (UIImage *)picker_fastestCompressImageWithSize:(CGFloat)size;
- (UIImage *)picker_fastestCompressImageWithSize:(CGFloat)size imageSize:(NSUInteger)imageSize;
/** 快速压缩 压缩到大约指定体积大小(kb) 返回data, 小于size指定大小，返回nil */
- (NSData *)picker_fastestCompressImageDataWithSize:(CGFloat)size;
- (NSData *)picker_fastestCompressImageDataWithSize:(CGFloat)size imageSize:(NSUInteger)imageSize;

/** 快速压缩 压缩到大约指定体积缩放 返回压缩后图片(动图) */
- (NSData *)picker_fastestCompressAnimatedImageDataWithScaleRatio:(CGFloat)ratio;


/** 根据图片大小和设置的最大宽度，返回缩放后的大小 */
+ (CGSize)picker_imageSizeBySize:(CGSize)size maxWidth:(CGFloat)maxWidth;

/** 缩放图片到指定大小 */
- (UIImage*)picker_scaleToSize:(CGSize)size;

/** 合并图片与文字 */
+ (UIImage *)picker_mergeImage:(UIImage *)image text:(NSString *)text;

+ (instancetype)picker_imageWithImagePath:(NSString *)imagePath;

+ (instancetype)picker_imageWithImagePath:(NSString *)imagePath error:(NSError **)error;

+ (instancetype)picker_imageWithImageData:(NSData *)imgData;

- (UIImage *)picker_decodedImage;
@end

NS_ASSUME_NONNULL_END
