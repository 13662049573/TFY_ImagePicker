//
//  NSBundle+picker.m
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "NSBundle+picker.h"

NSString *const ImagePickerDrakModel = @"_Drak";
NSString *const ImagePickerStrings = @"ImagePicker";

@implementation NSBundle (picker)

+ (instancetype)picker_mediaEditingBundle {
    static NSBundle *MediaEditingBundle = nil;
    if (MediaEditingBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        MediaEditingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[NSClassFromString(@"TFY_BaseEditingController") class]] pathForResource:ImagePickerStrings ofType:@"bundle"]];
    }
    return MediaEditingBundle;
}

+ (UIImage *)picker_imageNamed:(nullable NSString *)name
{
    return [self picker_imageNamed:name inDirectory:nil];
}

+ (UIImage *)picker_audioTrackImageNamed:(nullable NSString *)name
{
    return [self picker_editingimageNamed:name inDirectory:@"AudioTrack"];
}

+ (UIImage *)picker_brushImageNamed:(nullable NSString *)name
{
    return [self picker_editingimageNamed:name inDirectory:@"brush"];
}

+ (NSString *)picker_localizedStringForKey:(nullable NSString *)key
{
    return [self picker_localizedStringForKey:key value:nil];
}

+ (UIImage *)picker_editingimageNamed:(NSString *)name inDirectory:(NSString *)subpath
{
    NSString *extension = name.length ? (name.pathExtension.length ? name.pathExtension : @"png") : nil;
    NSString *defaultName = [name stringByDeletingPathExtension];
    NSString *bundleName = [defaultName stringByAppendingString:@"@2x"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[self picker_mediaEditingBundle] pathForResource:bundleName ofType:extension inDirectory:subpath]];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[[self picker_mediaEditingBundle] pathForResource:defaultName ofType:extension inDirectory:subpath]];
    }
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}


+ (NSString *)picker_localizedStringForKey:(nullable NSString *)key value:(nullable NSString *)value
{
    NSString *offile = [[NSBundle mainBundle] pathForResource:ImagePickerStrings ofType:@"bundle"];
    value = [[NSBundle bundleWithPath:offile] localizedStringForKey:key value:value table:ImagePickerStrings];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:ImagePickerStrings];
}

+ (NSString *)picker_stickersPath
{
    NSString *offile = [[[NSBundle mainBundle] pathForResource:ImagePickerStrings ofType:@"bundle"] stringByAppendingPathComponent:@"stickers"];
    return offile;
}


+(UIImage *)picker_fileImage:(NSString *)fileName inDirectory:(nullable NSString *)subpath {
    NSString *offile = [[[NSBundle mainBundle] pathForResource:ImagePickerStrings ofType:@"bundle" inDirectory:subpath] stringByAppendingPathComponent:fileName];
    return [UIImage imageWithContentsOfFile:offile];
}

+ (UIImage *)picker_imageNamed:(nullable NSString *)name inDirectory:(nullable NSString *)subpath
{
    NSString *defaultName = [name stringByDeletingPathExtension];
    NSString *bundleName = [defaultName stringByAppendingString:@"@2x"];
    UIImage *image = nil;
    if (@available(iOS 13.0, *)) {
        switch (UITraitCollection.currentTraitCollection.userInterfaceStyle) {
            case UIUserInterfaceStyleDark:
            {
                NSString *drakDefaultName = [defaultName stringByAppendingString:ImagePickerDrakModel];
                NSString *drakBundleName = [drakDefaultName stringByAppendingString:@"@2x"];
                if (image == nil) {
                    image = [self picker_fileImage:drakBundleName inDirectory:subpath];
                }
                if (image == nil) {
                    image = [self picker_fileImage:drakDefaultName inDirectory:subpath];
                }
            }
                break;
            default:
                break;
        }
    }
    if (image == nil) {
        image = [self picker_fileImage:bundleName inDirectory:subpath];
    }
    if (image == nil) {
        image = [self picker_fileImage:defaultName inDirectory:subpath];
    }
    if (image == nil) {
        image = [self picker_fileImage:name inDirectory:subpath];
    }
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end
