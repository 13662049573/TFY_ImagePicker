//
//  NSData+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "NSData+picker.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TFY_ImageCoder.h"

inline static UIImageOrientation CompressDecodedImage_UIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

#define kJRUTTypeHEIC ((__bridge CFStringRef)@"public.heic")
#define kJRUTTypeHEIF ((__bridge CFStringRef)@"public.heif")
#define kJRUTTypeHEICS ((__bridge CFStringRef)@"public.heics")
#define kJRUTTypeWebP ((__bridge CFStringRef)@"public.webp")

@implementation NSData (picker)

+ (TFYImageFormat)picker_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return TFYImageFormatUndefined;
    }
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return TFYImageFormatJPEG;
        case 0x89:
            return TFYImageFormatPNG;
        case 0x47:
            return TFYImageFormatGIF;
        case 0x49:
        case 0x4D:
            return TFYImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return TFYImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return TFYImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return TFYImageFormatHEIF;
                }
            }
            break;
        }
    }
    return TFYImageFormatUndefined;
}

+ (nonnull CFStringRef)picker_UTTypeFromImageFormat:(TFYImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case TFYImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case TFYImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case TFYImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case TFYImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case TFYImageFormatWebP:
            UTType = kJRUTTypeWebP;
            break;
        case TFYImageFormatHEIC:
            UTType = kJRUTTypeHEIC;
            break;
        case TFYImageFormatHEIF:
            UTType = kJRUTTypeHEIF;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

+ (TFYImageFormat)picker_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return TFYImageFormatUndefined;
    }
    TFYImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatTIFF;
    } else if (CFStringCompare(uttype, kJRUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatWebP;
    } else if (CFStringCompare(uttype, kJRUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatHEIC;
    } else if (CFStringCompare(uttype, kJRUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = TFYImageFormatHEIF;
    } else {
        imageFormat = TFYImageFormatUndefined;
    }
    return imageFormat;
}


- (UIImage * __nullable)picker_dataDecodedImageWithSize:(CGSize)size mode:(UIViewContentMode)mode
{
    CGImageSourceRef _imgSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self), NULL);
    if (_imgSourceRef) {
        NSUInteger count = CGImageSourceGetCount(_imgSourceRef);
        if (count > 0) {
            UIImageOrientation imgOrientation = UIImageOrientationUp;
            //exifInfo 包含了很多信息,有兴趣的可以打印看看,我们只需要Orientation这个字段
            CFDictionaryRef exifInfo = CGImageSourceCopyPropertiesAtIndex(_imgSourceRef, 0,NULL);
            if (exifInfo) {
                //判断Orientation这个字段,如果图片经过PS等处理,exif信息可能会丢失
                if(CFDictionaryContainsKey(exifInfo, kCGImagePropertyOrientation)){
                    CFNumberRef orientation = CFDictionaryGetValue(exifInfo, kCGImagePropertyOrientation);
                    NSInteger orientationValue = 0;
                    CFNumberGetValue(orientation, kCFNumberIntType, &orientationValue);
                    imgOrientation = CompressDecodedImage_UIImageOrientationFromEXIFValue(orientationValue);
                }
                CFRelease(exifInfo);
            }
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imgSourceRef, 0, NULL);
            CGImageRef decodeImageRef = picker_CGImageScaleDecodedFromCopy(imageRef, size, mode, imgOrientation);
            if (imageRef) {
                CGImageRelease(imageRef);
            }
            CFRelease(_imgSourceRef);
            if (decodeImageRef) {
                UIImage *image = [UIImage imageWithCGImage:decodeImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                CGImageRelease(decodeImageRef);
                return image;
            }
        }
    }
    return nil;
}

@end
