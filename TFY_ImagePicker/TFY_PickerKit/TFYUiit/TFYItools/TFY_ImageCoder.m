//
//  TFY_ImageCoder.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_ImageCoder.h"
#import <QuartzCore/QuartzCore.h>

double const TFYMediaEditMinRate = 0.5f;
double const TFYMediaEditMaxRate = 2.f;

CGRect TFYMediaEditProundRect(CGRect rect)
{
    rect.origin.x = ((int)(rect.origin.x+0.5)*1.f);
    rect.origin.y = ((int)(rect.origin.y+0.5)*1.f);
    rect.size.width = ((int)(rect.size.width+0.5)*1.f);
    rect.size.height = ((int)(rect.size.height+0.5)*1.f);
    return rect;
}

UIWindow* TFYAppWindow(void) {
    UIWindow *keywindow = UIApplication.sharedApplication.keyWindow;
    if (keywindow == nil) {
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    UIWindow *tmpWindow = nil;
                    if (@available(iOS 15.0, *)) {
                        tmpWindow = scene.keyWindow;
                    }
                    if (tmpWindow == nil) {
                        for (UIWindow *window in scene.windows) {
                            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                                tmpWindow = window;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    if (keywindow == nil) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                keywindow = window;
                break;
            }
        }
    }
    return keywindow;
}



inline static CGAffineTransform pickerGifView_CGAffineTransformExchangeOrientation(UIImageOrientation imageOrientation, CGSize size)
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

#pragma mark - public
CGImageRef picker_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size, UIViewContentMode contentMode, UIImageOrientation orientation)
{
    CGImageRef newImage = NULL;
    @autoreleasepool {
        if (!imageRef) return NULL;
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) return NULL;
        
        switch (orientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
            {
                CGFloat tmpWidth = width;
                width = height;
                height = tmpWidth;
            }
                break;
            default:
                break;
        }
        
        if (size.width > 0 && size.height > 0) {
            float verticalRadio = size.height*1.0/height;
            float horizontalRadio = size.width*1.0/width;
            
            
            float radio = 1;
            if (contentMode == UIViewContentModeScaleAspectFill) {
                if(verticalRadio > horizontalRadio)
                {
                    radio = verticalRadio;
                }
                else
                {
                    radio = horizontalRadio;
                }
            } else if (contentMode == UIViewContentModeScaleAspectFit) {
                if(verticalRadio < horizontalRadio)
                {
                    radio = verticalRadio;
                }
                else
                {
                    radio = horizontalRadio;
                }
            } else {
                if(verticalRadio>1 && horizontalRadio>1)
                {
                    radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
                }
                else
                {
                    radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
                }
                
            }
            
            width = roundf(width*radio);
            height = roundf(height*radio);
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        CGAffineTransform transform = pickerGifView_CGAffineTransformExchangeOrientation(orientation, CGSizeMake(width, height));
        // BGRA8888 (premultiplied) or BGRX8888
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, bitmapInfo);
        CGColorSpaceRelease(colorSpace);
        if (!context) return NULL;
        CGContextConcatCTM(context, transform);
        switch (orientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(context, CGRectMake(0, 0, height, width), imageRef); // decode
                break;
            default:
                CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
                break;
        }
        newImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
    }
    return newImage;
}

CGImageRef picker_CGImageDecodedFromCopy(CGImageRef imageRef)
{
    return picker_CGImageScaleDecodedFromCopy(imageRef, CGSizeZero, UIViewContentModeScaleAspectFit, UIImageOrientationUp);
}


CGImageRef picker_CGImageDecodedCopy(UIImage *image)
{
    if (!image) return NULL;
    if (image.images.count > 1) {
        return NULL;
    }
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) return NULL;
    CGImageRef newImageRef = picker_CGImageDecodedFromCopy(imageRef);
    
    return newImageRef;
}

UIImage *picker_UIImageDecodedCopy(UIImage *image)
{
    CGImageRef imageRef = picker_CGImageDecodedCopy(image);
    if (!imageRef) return image;
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return newImage;
}



