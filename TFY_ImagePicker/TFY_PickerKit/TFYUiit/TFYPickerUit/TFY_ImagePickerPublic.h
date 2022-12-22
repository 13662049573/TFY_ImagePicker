//
//  TFY_ImagePickerPublic.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/21.
//


#import <UIKit/UIKit.h>
#import "TFYCategory.h"

typedef NSString * kImageInfoFileKey NS_STRING_ENUM;

typedef NS_ENUM(NSUInteger, TFYImagePickerSubMediaType) {
    TFYImagePickerSubMediaTypeNone = 0,
    
    TFYImagePickerSubMediaTypeGIF = 10,
    TFYImagePickerSubMediaTypeLivePhoto,
};

typedef NS_ENUM(NSUInteger, TFYPickingMediaType) {
    /** None */
    TFYPickingMediaTypeNone = 0,
    /** Whether the user can picking a photo */
    TFYPickingMediaTypePhoto = 1 << 0,
    /** Whether the user can picking a gif */
    TFYPickingMediaTypeGif = 1 << 1,
    /** Whether the user can picking a livePhoto(gif) */
    TFYPickingMediaTypeLivePhoto = 1 << 2,
    /** Whether the user can picking a video */
    TFYPickingMediaTypeVideo = 1 << 3,
    /** Users can picking all media types */
    TFYPickingMediaTypeALL = ~0UL,
};

#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define picker_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define dispatch_globalQueue_async_safe(block)\
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

#define bundleImageNamed(name) [NSBundle picker_imageNamed:name]

/** 视频时间（取整：四舍五入） */
extern NSTimeInterval picker_videoDuration(NSTimeInterval duration);
/** 是否长图 */
extern BOOL picker_isPiiic(CGSize imageSize);
/** 是否横图 */
extern BOOL picker_isHor(CGSize imageSize);

/** 标清图压缩大小 */
extern float const kCompressSize;
/** 缩略图压缩大小 */
extern float const kThumbnailCompressSize;
/** 图片最大大小 */
extern float const kMaxPhotoBytes;
/** 视频最大时长 */
extern float const kMaxVideoDurationze;

/** UIControlStateHighlighted 高亮透明度 */
extern float const kControlStateHighlightedAlpha;

