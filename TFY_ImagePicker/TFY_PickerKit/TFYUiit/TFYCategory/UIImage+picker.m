//
//  UIImage+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "UIImage+picker.h"
#import <Accelerate/Accelerate.h>
#import "TFYItools.h"

#define _FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))
#define _TWO_CC(c1,c2) ((uint16_t)(((c2) << 8) | (c1)))

TFYPickerImageType TFYImageDetectType(CFDataRef data) {
    if (!data) return TFYPickerImageType_Unknow;
    uint64_t length = CFDataGetLength(data);
    if (length < 16) return TFYPickerImageType_Unknow;
    
    const char *bytes = (char *)CFDataGetBytePtr(data);
    
    uint32_t magic4 = *((uint32_t *)bytes);
    switch (magic4) {
        case _FOUR_CC(0x4D, 0x4D, 0x00, 0x2A): { // big endian TIFF
            return TFYPickerImageType_TIFF;
        } break;
            
        case _FOUR_CC(0x49, 0x49, 0x2A, 0x00): { // little endian TIFF
            return TFYPickerImageType_TIFF;
        } break;
            
        case _FOUR_CC(0x00, 0x00, 0x01, 0x00): { // ICO
            return TFYPickerImageType_ICO;
        } break;
            
        case _FOUR_CC('i', 'c', 'n', 's'): { // ICNS
            return TFYPickerImageType_ICNS;
        } break;
            
        case _FOUR_CC('G', 'I', 'F', '8'): { // GIF
            return TFYPickerImageType_GIF;
        } break;
            
        case _FOUR_CC(0x89, 'P', 'N', 'G'): {  // PNG
            uint32_t tmp = *((uint32_t *)(bytes + 4));
            if (tmp == _FOUR_CC('\r', '\n', 0x1A, '\n')) {
                return TFYPickerImageType_PNG;
            }
        } break;
            
        case _FOUR_CC('R', 'I', 'F', 'F'): { // WebP
            uint32_t tmp = *((uint32_t *)(bytes + 8));
            if (tmp == _FOUR_CC('W', 'E', 'B', 'P')) {
                return TFYPickerImageType_WebP;
            }
        } break;
    }
    
    uint16_t magic2 = *((uint16_t *)bytes);
    switch (magic2) {
        case _TWO_CC('B', 'A'):
        case _TWO_CC('B', 'M'):
        case _TWO_CC('I', 'C'):
        case _TWO_CC('P', 'I'):
        case _TWO_CC('C', 'I'):
        case _TWO_CC('C', 'P'): { // BMP
            return TFYPickerImageType_BMP;
        }
        case _TWO_CC(0xFF, 0x4F): { // JPEG2000
            return TFYPickerImageType_JPEG2000;
        }
    }
    if (memcmp(bytes,"\377\330\377",3) == 0) return TFYPickerImageType_JPEG;
    if (memcmp(bytes + 4, "\152\120\040\040\015", 5) == 0) return TFYPickerImageType_JPEG2000;
    return TFYPickerImageType_Unknow;
}

@implementation UIImage (picker)

+ (instancetype)picker_imageWithImagePath:(NSString *)imagePath
{
    return [self picker_imageWithImagePath:imagePath error:nil];
}

+ (instancetype)picker_imageWithImagePath:(NSString *)imagePath error:(NSError **)error
{
    if (imagePath.length == 0) return nil;
    NSError *dataError = nil;
    NSData *imgData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedIfSafe error:&dataError];
    if (dataError != nil) {
        NSLog(@"%@", dataError.localizedDescription);
        if (error) {
            *error = dataError;
        }
        return nil;
    }
    
    return [self picker_imageWithImageData:imgData];
}

+ (instancetype)picker_imageWithImageData:(NSData *)imgData
{
    TFYPickerImageType imageType = TFYImageDetectType((__bridge CFDataRef)imgData);
    
    UIImage *image = nil;
    switch (imageType) {
        case TFYPickerImageType_GIF:
            image = [self picker_animatedGIFWithData:imgData];
            break;
        default:
            image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
            break;
    }
    return image;
}

+ (UIImage *)picker_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self picker_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)picker_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}


- (UIImage *)picker_fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp) return self;
    UIImage *editImg = self;//[UIImage imageWithData:UIImagePNGRepresentation(self)];
    CGAffineTransform transform = [UIImage picker_exchangeOrientation:editImg.imageOrientation size:editImg.size];
    CGContextRef ctx = CGBitmapContextCreate(NULL, editImg.size.width, editImg.size.height,
                                             CGImageGetBitsPerComponent(editImg.CGImage), 0,
                                             CGImageGetColorSpace(editImg.CGImage),
                                             CGImageGetBitmapInfo(editImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (editImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0, editImg.size.height, editImg.size.width), editImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0, editImg.size.width, editImg.size.height), editImg.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return img;
}

+ (CGAffineTransform)picker_exchangeOrientation:(UIImageOrientation)imageOrientation size:(CGSize)size
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

+ (CGSize)picker_scaleImageSizeBySize:(CGSize)imageSize targetSize:(CGSize)size isBoth:(BOOL)isBoth {
    
    /** 原图片大小为0 不再往后处理 */
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return imageSize;
    }
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (isBoth) {
            if(widthFactor > heightFactor){
                scaleFactor = widthFactor;
            }
            else{
                scaleFactor = heightFactor;
            }
        } else {
            if(widthFactor > heightFactor){
                scaleFactor = heightFactor;
            }
            else{
                scaleFactor = widthFactor;
            }
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    return CGSizeMake(ceilf(scaledWidth), ceilf(scaledHeight));
}

- (UIImage*)picker_scaleToFitSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = roundf(width*radio);
    height = roundf(height*radio);
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage*)picker_scaleToFillSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    
    // 创建一个context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

//截取部分图像
- (UIImage *)picker_cropInRect:(CGRect)rect
{
    if (CGPointEqualToPoint(CGPointZero, rect.origin) && CGSizeEqualToSize(self.size, rect.size)) {
        return self;
    }
    UIImage *smallImage = nil;
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    if (newImageRef) {
        smallImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(newImageRef);
    }

    return smallImage;
}

/** 合并图片（图片大小一致） */
- (UIImage *)picker_mergeimages:(NSArray <UIImage *>*)images
{
    UIGraphicsBeginImageContextWithOptions(self.size ,NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    for (UIImage *image in images) {
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mergeImage;
}

/** 合并图片(图片大小以第一张为准) */
+ (UIImage *)picker_mergeimages:(NSArray <UIImage *>*)images
{
    UIGraphicsBeginImageContextWithOptions(images.firstObject.size ,NO, images.firstObject.scale);
    for (UIImage *image in images) {
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mergeImage;
}

/** 将图片旋转弧度radians */
- (UIImage *)picker_imageRotatedByRadians:(CGFloat)radians
{
    // calculate the size of the rotated view's containing box for our drawing space
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    CGRect clipTransRect = CGRectApplyAffineTransform(CGRectMake(0,0,self.size.width, self.size.height), t);
    CGSize rotatedSize = clipTransRect.size;
    rotatedSize.width = ((int)(rotatedSize.width+0.5)*1.f);
    rotatedSize.height = ((int)(rotatedSize.height+0.5)*1.f);
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, radians);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIColor *)picker_colorAtPixel:(CGPoint)point {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
- (UIImage *)picker_transToMosaicLevel:(NSUInteger)level
{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGBitmapByteOrderDefault,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage ;
}

// 添加通用模糊效果
// image是图片，blur是模糊度
- (UIImage *)picker_transToBlurLevel:(NSUInteger)blurRadius
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    
    if (!self.CGImage) {
        
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    
    CGRect   imageRect   = { CGPointZero, self.size };
    UIImage *effectImage = self;
    CGFloat saturationDeltaFactor = 1.4f;
    UIColor *tintColor = [UIColor colorWithWhite:0 alpha:0.0];
    
    BOOL hasBlur             = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
        }
        
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            
            if (hasBlur) {
                
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
                
            } else {
                
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        
        if (!effectImageBuffersAreSwapped) {
            
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped) {
            
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        
        CGContextSaveGState(outputContext);
        
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)picker_tipGuideViewMaskImage:(UIColor *)maskColor
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextSetFillColorWithColor(context, maskColor.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}

- (CGAffineTransform)picker_preferredTransform {
    if (self.imageOrientation == UIImageOrientationUp) {
        return CGAffineTransformIdentity;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize imageSize = CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, imageSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, imageSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

/** 快速压缩 压缩到大约指定体积大小(kb) 返回压缩后图片 */
- (UIImage *)picker_fastestCompressImageWithSize:(CGFloat)size
{
    return [self picker_fastestCompressImageWithSize:size imageSize:0];
}

- (UIImage *)picker_fastestCompressImageWithSize:(CGFloat)size imageSize:(NSUInteger)imageSize
{
    NSData *imageData = [self picker_fastestCompressImageSize:size imageSize:imageSize];
    UIImage *compressedImage = nil;
    if (imageData) {
        compressedImage = [UIImage imageWithData:imageData scale:self.scale];
    }
    if (!compressedImage) {
        return self;
    }
    return compressedImage;
}

/** 快速压缩 压缩到大约指定体积大小(kb) 返回data */
- (NSData *)picker_fastestCompressImageDataWithSize:(CGFloat)size
{
    return [self picker_fastestCompressImageDataWithSize:size imageSize:0];
}

- (NSData *)picker_fastestCompressImageDataWithSize:(CGFloat)size imageSize:(NSUInteger)imageSize
{
    return [self picker_fastestCompressImageSize:size imageSize:imageSize];
}

#pragma mark - 压缩图片接口
- (NSData *)picker_fastestCompressImageSize:(CGFloat)size imageSize:(NSUInteger)imageSize
{
    @autoreleasepool {
        /** 临时图片 */
        UIImage *compressedImage = self;
        CGFloat targetSize = size * 1024; // 压缩目标大小
        CGFloat defaultPercent = 0.65f; // 压缩系数
        CGFloat percent = defaultPercent;
        /** 微调参数 */
        NSInteger microAdjustment = 8*1024;
        /** 设备分辨率 */
        CGSize pixel = [UIImage picker_appPixel];
        /** 缩放图片尺寸 */
        int MIN_UPLOAD_RESOLUTION = pixel.width * pixel.height;
        /** 当前图片尺寸 */
        float currentResolution = self.size.height * self.size.width;
        /** 偏移量 */
        float offsetSize = size * 0.2 * 1024;
        
        /** 图片大小 */
        long long imageLength = imageSize;
        NSData *imageData = nil;
        
        if (imageLength == 0) {
            imageData = picker_UIImageJPEGRepresentation(self, 1);
            imageLength = imageData.length;
            /** 没有需要压缩的必要，直接返回 */
            if (imageLength <= targetSize) return nil;
        } else {
            /** 没有需要压缩的必要，直接返回 */
            if (imageLength <= targetSize) return nil;
        }
        
        /** 缩放图片 */
        if (currentResolution > MIN_UPLOAD_RESOLUTION) {
            float factor = sqrt(currentResolution / MIN_UPLOAD_RESOLUTION) * 2;
            compressedImage = [self picker_scaleWithSize:CGSizeMake(self.size.width / factor, self.size.height / factor)];
        }
        
        percent *= (targetSize/imageLength);
        
        /** 记录上一次的压缩大小 */
        NSInteger imageDatalength = 0;
        
        /** 压缩核心方法 */
        do {
            
            imageData = picker_UIImageJPEGRepresentation(compressedImage, percent);
            
            CGFloat diffSize = imageData.length - targetSize;
            
            if (diffSize > targetSize/3) { /** 压缩后与期望值相差超过1/3 */
                percent -=.2f;
            } else if (diffSize < microAdjustment) { // 压缩精确度调整
                percent -= .02f; // 微调
            } else {
                percent -= .1f;
            }
            
            if (percent < 0.01) {
                /** 压缩系数不能少于0 */
                percent = 0.1;
            }
            
            // 大小没有改变 & 压缩后大小可能会微略变大的情况
            if (imageDatalength > 0 && imageData.length >= imageDatalength) {
                // 压缩大小没有改变，需要调整图片尺寸
                float scale = (targetSize/diffSize);
                if (scale < .5f) scale = 0.5f;
                if (scale > .85f) scale = 0.85f;
                compressedImage = [self picker_scaleWithSize:CGSizeMake(compressedImage.size.width * scale, compressedImage.size.height * scale)];
            }
            imageDatalength = imageData.length;
        } while (imageData.length > targetSize+offsetSize);/** 增加偏移量 */
        
        return imageData;
    }
}

/** 快速压缩 压缩到大约指定体积缩放 返回压缩后图片(动图) */
- (NSData *)picker_fastestCompressAnimatedImageDataWithScaleRatio:(CGFloat)ratio
{
    @autoreleasepool {
        if (self.images.count == 0) return nil;
        
        NSMutableArray *images = [@[] mutableCopy];
        
        CGSize imageSize = CGSizeMake(self.size.width*ratio, self.size.height*ratio);
        for (UIImage *subImage in self.images) {
            UIImage *compressImage = [subImage picker_scaleWithSize:imageSize];
            [images addObject:compressImage];
        }
        
        UIImage *aminatedImage = [UIImage animatedImageWithImages:images duration:self.duration];
        
        return picker_UIImageGIFRepresentation(aminatedImage);
    }
}

#pragma mark - 缩放图片尺寸
- (UIImage*)picker_scaleWithSize:(CGSize)newSize
{
    
    if (newSize.width*newSize.height > self.size.width*self.size.height) {
        return self;
    }
    //We prepare a bitmap with the new size
    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    
    //Draws a rect for the image
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //We set the scaled image from the context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

/** 设备分辨率 */
+ (CGSize)picker_appPixel
{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    
    CGFloat scale_screen = 1.0;//[UIScreen mainScreen].scale;
    
    CGFloat width = size_screen.width*scale_screen;
    CGFloat height = size_screen.height*scale_screen;
    
    return CGSizeMake(width, height);
}

- (CGImageRef)picker_cgFixOrientation {
    // No-op if the orientation is already correct
    
    UIImage *editImg = self;//[UIImage imageWithData:UIImagePNGRepresentation(self)];
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);

    // CGImage gets the size in normal direction.
    CGSize size = [UIImage picker_exchangeSizeWithOrientation:editImg.imageOrientation size:CGSizeMake(width, height)];
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = [UIImage picker_exchangeTransformWithOrientation:editImg.imageOrientation size:size];
    
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, size.width, size.height,
                                             CGImageGetBitsPerComponent(editImg.CGImage), 0,
                                             CGImageGetColorSpace(editImg.CGImage),
                                             CGImageGetBitmapInfo(editImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (editImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0, size.height, size.width), editImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0, size.width, size.height), editImg.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    
    CGContextRelease(ctx);
    
    return cgimg;
}

+ (CGSize)picker_exchangeSizeWithOrientation:(UIImageOrientation)imageOrientation size:(CGSize)size
{
    CGSize exSize;
    switch (imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            exSize = CGSizeMake(size.height, size.width);
            break;
            
        default:
            exSize = CGSizeMake(size.width, size.height);
            break;
    }
    return exSize;
}

+ (CGAffineTransform)picker_exchangeTransformWithOrientation:(UIImageOrientation)imageOrientation size:(CGSize)size
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

+ (CGSize)picker_imageSizeBySize:(CGSize)size maxWidth:(CGFloat)maxWidth
{
    if (maxWidth == 0) return size;
    CGFloat scaleFactor = maxWidth / size.width;
    CGFloat width = maxWidth;
    CGFloat height = size.height * scaleFactor;
    
    return CGSizeMake(ceilf(width), ceilf(height));
}

- (UIImage*)picker_scaleToSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = floorf(width*radio);
    height = floorf(height*radio);
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

/** 合并图片与文字 */
+ (UIImage *)picker_mergeImage:(UIImage *)image text:(NSString *)text
{
    UIImage *outputImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        [[UIColor clearColor] setFill];
        
        UIFont *font = [UIFont boldSystemFontOfSize:15.0];//设置
        [image drawAtPoint:CGPointZero];
        CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
        [text drawInRect:CGRectMake((image.size.width-size.width)/2, (image.size.height-size.height)/2, size.width, size.height) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor whiteColor]}];
        outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return outputImage;
}

- (UIImage *)picker_decodedImage
{
    @autoreleasepool {
        CGImageRef imageRef = self.CGImage;
        if (!imageRef) return self;
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) return self;
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        // BGRA8888 (premultiplied) or BGRX8888
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        if (!context) return self;
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef newImageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        if (!newImageRef) return self;
        UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(newImageRef);
        return newImage;
    }
    
    return self;
}

@end
