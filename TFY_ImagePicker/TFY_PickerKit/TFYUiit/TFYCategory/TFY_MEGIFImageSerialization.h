//
//  TFY_MEGIFImageSerialization.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageGIFRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageGIFRepresentation(UIImage * image, NSTimeInterval duration, NSUInteger loopCount, NSError * _Nullable __autoreleasing * _Nullable error);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageGIFRepresentation(UIImage * image, NSArray<NSNumber *> * durations, NSUInteger loopCount, NSError * _Nullable __autoreleasing * _Nullable error);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImagePNGRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageJPEGRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageRepresentation(UIImage * image, CFStringRef __nonnull type, NSError * _Nullable __autoreleasing * _Nullable error);


extern __attribute__((overloadable)) NSArray<NSNumber *> * _Nullable picker_UIImageGIFDurationsFromData(NSData *data, NSError * _Nullable __autoreleasing * _Nullable error);


extern __attribute__((overloadable)) NSData * _Nullable picker_UIImagePNGRepresentation(UIImage * _Nonnull image, CGFloat compressionQuality);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageJPEGRepresentation(UIImage * _Nonnull image, CGFloat compressionQuality);

extern __attribute__((overloadable)) NSData * _Nullable picker_UIImageRepresentation(UIImage * _Nonnull image, CGFloat compressionQuality, CFStringRef __nonnull type, NSError * _Nullable __autoreleasing * _Nullable error);


NS_ASSUME_NONNULL_END
