//
//  NSBundle+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (picker)
+ (instancetype)picker_mediaEditingBundle;
+ (UIImage *)picker_imageNamed:(nullable NSString *)name;
+ (UIImage *)picker_audioTrackImageNamed:(nullable NSString *)name;
+ (UIImage *)picker_brushImageNamed:(nullable NSString *)name;
+ (NSString *)picker_localizedStringForKey:(nullable NSString *)key;
+ (NSString *)picker_stickersPath;
+ (NSString *)picker_localizedStringForKey:(nullable NSString *)key value:(nullable NSString *)value;
@end

NS_ASSUME_NONNULL_END
