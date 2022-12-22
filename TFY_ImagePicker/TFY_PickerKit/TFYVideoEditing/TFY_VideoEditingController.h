//
//  TFY_VideoEditingController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BaseEditingController.h"
#import <AVFoundation/AVFoundation.h>
#import "TFYVideoUit.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYVideoEditOperationType) {
    /** 绘画 */
    TFYVideoEditOperationType_draw = 1 << 0,
    /** 贴图 */
    TFYVideoEditOperationType_sticker = 1 << 1,
    /** 文本 */
    TFYVideoEditOperationType_text = 1 << 2,
    /** 音频 */
    TFYVideoEditOperationType_audio = 1 << 3,
    /** 滤镜 */
    TFYVideoEditOperationType_filter NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 4,
    /** 速率 */
    TFYVideoEditOperationType_rate = 1 << 5,
    /** 剪辑 */
    TFYVideoEditOperationType_clip = 1 << 6,
    /** 所有 */
    TFYVideoEditOperationType_All = ~0UL,
};

typedef NSString * TFYVideoEditOperationStringKey NS_EXTENSIBLE_STRING_ENUM;
/************************ Attributes ************************/
/**
 * 以下属性仅对未编辑过对象生效，若是已经编辑过的对象（LFVideoEdit）忽略该属性。
 * The following properties are only valid for unedited objects. If the object has been edited (LFVideoEdit), the attribute is ignored.
 */

/**
 绘画的默认颜色
 The default color of the painting.
 
 NSNumber containing LFVideoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditDrawColorAttributeName;
/**
 绘画的默认笔刷
 The default brush of the painting.
 
 NSNumber containing LFVideoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditDrawBrushAttributeName;
/**
 详细请看TFY_StickerContent.h。
 所有资源不适宜过大。开发者需要把控数据大小。防止内存崩溃。
 
 See TFY_StickerContent.h for details.
 All resources should not be too large. Developers need to control the size of the data. Prevent memory crash.
 
 @{TFYVideoEditStickerContentsAttributeName:@[
    // 第一个标签的数据。
    // Data for the first tab.
    [TFY_StickerContent stickerContentWithTitle:@"Tab Name" contents:@[@"Tab Datas"]],
    // 第二个标签的数据。
    // Data for the second tab.
    [TFY_StickerContent stickerContentWithTitle:@"Tab Name" contents:@[@"Tab Datas"]],
    ......
 ]}
 
 NSArray containing NSArray<LFStickerContent *>, default
 @[
    [TFY_StickerContent stickerContentWithTitle:@"默认" contents:@[TFYStickerContentDefaultSticker]],
    [TFY_StickerContent stickerContentWithTitle:@"相册" contents:@[TFYStickerContentAllAlbum]]
 ].
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditStickerContentsAttributeName;
/**
 文字的默认颜色
 The default color of the text.
 
 NSNumber containing LFVideoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditTextColorAttributeName;
/**
 默认音轨是否静音🔇
 Set the default track mute🔇
 
 NSNumber containing BOOL, default false: default audioTrack ,true: mute.
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditAudioMuteAttributeName;
/**
 自定义音轨资源路径，完整的资源路径目录file://...。将该目录下的所有文件作为可选音轨。它没有任何判断，请确保目录内的文件都是可播放的音频文件。
 The audio tracks are customizable. This path must be a full path directory (for example: file://... ). All files in the directory as audio tracks. It does not have any judgment logic, please make sure that the files in the directory are all playable audio files.
 
 NSArray containing NSURL(fileURLWithPath:), default nil. audio resource paths.
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditAudioUrlsAttributeName;
/**
 滤镜的默认类型
 The default type of the filter.
 
 NSNumber containing TFYVideoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditFilterAttributeName;
/**
 播放速率
 Play rate
 
 NSNumber containing double, default 1, Range of 0.5 to 2.0.
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditRateAttributeName;
/**
 剪辑的最小时刻
 Minimum moment of the clip
 
 NSNumber containing double, default 1.0. Must be greater than 0 and less than TFYVideoEditClipMaxDurationAttributeName, otherwise invalid. In general, it is an integer
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditClipMinDurationAttributeName;
/**
 剪辑的最大时刻
 Maximum moment of the clip
 
 NSNumber containing double, default 0. Must be greater than min, otherwise invalid. 0 is not limited. In general, it is an integer
 */
UIKIT_EXTERN TFYVideoEditOperationStringKey const TFYVideoEditClipMaxDurationAttributeName;
/************************ Attributes ************************/

typedef NS_ENUM(NSUInteger, TFYVideoEditOperationSubType) {
    
    /** TFYVideoEditOperationType_draw && TFYVideoEditDrawColorAttributeName */
    
    TFYVideoEditOperationSubTypeDrawWhiteColor = 1,
    TFYVideoEditOperationSubTypeDrawBlackColor,
    TFYVideoEditOperationSubTypeDrawRedColor,
    TFYVideoEditOperationSubTypeDrawLightYellowColor,
    TFYVideoEditOperationSubTypeDrawYellowColor,
    TFYVideoEditOperationSubTypeDrawLightGreenColor,
    TFYVideoEditOperationSubTypeDrawGreenColor,
    TFYVideoEditOperationSubTypeDrawAzureColor,
    TFYVideoEditOperationSubTypeDrawRoyalBlueColor,
    TFYVideoEditOperationSubTypeDrawBlueColor,
    TFYVideoEditOperationSubTypeDrawPurpleColor,
    TFYVideoEditOperationSubTypeDrawLightPinkColor,
    TFYVideoEditOperationSubTypeDrawVioletRedColor,
    TFYVideoEditOperationSubTypeDrawPinkColor,
    
    /** TFYVideoEditOperationType_draw && TFYVideoEditDrawBrushAttributeName */
    TFYVideoEditOperationSubTypeDrawPaintBrush = 50,
    TFYVideoEditOperationSubTypeDrawHighlightBrush,
    TFYVideoEditOperationSubTypeDrawChalkBrush,
    TFYVideoEditOperationSubTypeDrawFluorescentBrush,
    TFYVideoEditOperationSubTypeDrawStampAnimalBrush,
    TFYVideoEditOperationSubTypeDrawStampFruitBrush,
    TFYVideoEditOperationSubTypeDrawStampHeartBrush,
    
    /** TFYVideoEditOperationType_text && TFYVideoEditTextColorAttributeName */
    
    TFYVideoEditOperationSubTypeTextWhiteColor = 100,
    TFYVideoEditOperationSubTypeTextBlackColor,
    TFYVideoEditOperationSubTypeTextRedColor,
    TFYVideoEditOperationSubTypeTextLightYellowColor,
    TFYVideoEditOperationSubTypeTextYellowColor,
    TFYVideoEditOperationSubTypeTextLightGreenColor,
    TFYVideoEditOperationSubTypeTextGreenColor,
    TFYVideoEditOperationSubTypeTextAzureColor,
    TFYVideoEditOperationSubTypeTextRoyalBlueColor,
    TFYVideoEditOperationSubTypeTextBlueColor,
    TFYVideoEditOperationSubTypeTextPurpleColor,
    TFYVideoEditOperationSubTypeTextLightPinkColor,
    TFYVideoEditOperationSubTypeTextVioletRedColor,
    TFYVideoEditOperationSubTypeTextPinkColor,
    
    /** TFYVideoEditOperationType_filter && TFYVideoEditFilterAttributeName */
    
    TFYVideoEditOperationSubTypeLinearCurveFilter = 400,
    TFYVideoEditOperationSubTypeChromeFilter,
    TFYVideoEditOperationSubTypeFadeFilter,
    TFYVideoEditOperationSubTypeInstantFilter,
    TFYVideoEditOperationSubTypeMonoFilter,
    TFYVideoEditOperationSubTypeNoirFilter,
    TFYVideoEditOperationSubTypeProcessFilter,
    TFYVideoEditOperationSubTypeTonalFilter,
    TFYVideoEditOperationSubTypeTransferFilter,
    TFYVideoEditOperationSubTypeCurveLinearFilter,
    TFYVideoEditOperationSubTypeInvertFilter,
    TFYVideoEditOperationSubTypeMonochromeFilter,
    
};

@class TFY_VideoEditingController;

@protocol TFYVideoEditingControllerDelegate <NSObject>

- (void)picker_VideoEditingControllerDidCancel:(TFY_VideoEditingController *)videoEditingVC;
- (void)picker_VideoEditingController:(TFY_VideoEditingController *)videoEditingVC didFinishPhotoEdit:(TFY_VideoEdit *)videoEdit;

@end

@interface TFY_VideoEditingController : TFY_BaseEditingController

/** 编辑视频 */
@property (nonatomic, readonly) UIImage *placeholderImage;
@property (nonatomic, readonly) AVAsset *asset;
/**
 设置编辑图片->重新初始化
 Set edit photo -> init
 */
- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image;
/**
 设置编辑对象->重新编辑
 Set edit object -> re-edit
 */
- (void)setVideoEdit:(TFY_VideoEdit *)videoEdit;

/**
 设置操作类型
 The type of operation.
 default is TFYVideoEditOperationType_All
 */
@property (nonatomic, assign) TFYVideoEditOperationType operationType;
/**
 设置默认的操作类型，可以选择最多2种操作，优先级以operationType类型为准。
 1、TFYVideoEditOperationType_clip优于所有类型。所有类型可与TFYVideoEditOperationType_clip搭配；
 2、TFYVideoEditOperationType_clip以外的其它类型搭配以优先级排序仅显示1种。
 ps:当operationType 与 defaultOperationType 只有TFYVideoEditOperationType_clip的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 */
@property (nonatomic, assign) TFYVideoEditOperationType defaultOperationType;
/**
 操作属性设置，根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
 The operation attribute is based on the operationType, and the corresponding default value is set for different operations.
 */
@property (nonatomic, strong) NSDictionary<TFYVideoEditOperationStringKey, id> *operationAttrs;

/** 代理 */
@property (nonatomic, weak) id<TFYVideoEditingControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
