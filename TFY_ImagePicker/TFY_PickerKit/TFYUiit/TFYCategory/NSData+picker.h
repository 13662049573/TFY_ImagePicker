//
//  NSData+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSInteger TFYImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const TFYImageFormat TFYImageFormatUndefined = -1;
static const TFYImageFormat TFYImageFormatJPEG      = 0;
static const TFYImageFormat TFYImageFormatPNG       = 1;
static const TFYImageFormat TFYImageFormatGIF       = 2;
static const TFYImageFormat TFYImageFormatTIFF      = 3;
static const TFYImageFormat TFYImageFormatWebP      = 4;
static const TFYImageFormat TFYImageFormatHEIC      = 5;
static const TFYImageFormat TFYImageFormatHEIF      = 6;

NS_ASSUME_NONNULL_BEGIN

@interface NSData (picker)

+ (TFYImageFormat)picker_imageFormatForImageData:(nullable NSData *)data;

+ (nonnull CFStringRef)picker_UTTypeFromImageFormat:(TFYImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(sd_UTType(from:));

+ (TFYImageFormat)picker_imageFormatFromUTType:(nonnull CFStringRef)uttype;

- (UIImage * __nullable)picker_dataDecodedImageWithSize:(CGSize)size mode:(UIViewContentMode)mode;

@end

NS_ASSUME_NONNULL_END
