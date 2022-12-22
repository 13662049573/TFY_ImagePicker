//
//  TFY_PhotoEditingController.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_BaseEditingController.h"
#import "TFY_StickerContent.h"
#import "TFY_PhotoEdit.h"
#import "TFY_ExtraAspectRatio.h"

@class TFY_PhotoEditingController;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TFYPhotoEditOperationType) {
    /** 绘画 */
    TFYPhotoEditOperationType_draw = 1 << 0,
    /** 贴图 */
    TFYPhotoEditOperationType_sticker = 1 << 1,
    /** 文本 */
    TFYPhotoEditOperationType_text = 1 << 2,
    /** 模糊 */
    TFYPhotoEditOperationType_splash = 1 << 3,
    /** 滤镜 */
    TFYPhotoEditOperationType_filter NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 4,
    /** 修剪 */
    TFYPhotoEditOperationType_crop = 1 << 5,
    /** 所有 */
    TFYPhotoEditOperationType_All = ~0UL,
};

typedef NSString * TFYPhotoEditOperationStringKey NS_EXTENSIBLE_STRING_ENUM;
/************************ Attributes ************************/
/**
 * 以下属性仅对未编辑过对象生效，若是已经编辑过的对象（LFPhotoEdit）忽略该属性。
 */

/**
 绘画的默认颜色
 The default color of the painting.
 
 NSNumber containing TFYPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditDrawColorAttributeName;
/**
 绘画的默认笔刷
 The default brush of the painting.
 
 NSNumber containing TFYPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditDrawBrushAttributeName;
/**
 详细请看LFStickerContent.h。
 所有资源不适宜过大。开发者需要把控数据大小。防止内存崩溃。
 
 See TFY_StickerContent.h for details.
 All resources should not be too large. Developers need to control the size of the data. Prevent memory crash.
 
 @{TFYPhotoEditStickerContentsAttributeName:@[
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
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditStickerContentsAttributeName;
/**
 文字的默认颜色
 The default color of the text.
 
 NSNumber containing TFYPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditTextColorAttributeName;
/**
 模糊的默认类型
 The default type of the blur.
 
 NSNumber containing TFYPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditSplashAttributeName;
/**
 滤镜的默认类型
 The default type of the filter.
 
 NSNumber containing TFYPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditFilterAttributeName;
/**
 默认剪切比例。如果是自定义比例，需要从TFYPhotoEditOperationSubTypeCropAspectRatioOriginal开始计算。
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditCropAspectRatioAttributeName;
/**
 允许剪切旋转
Allow rotation.
 
 NSNumber containing TFYPhotoEditOperationSubType, default YES
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditCropCanRotateAttributeName;
/**
 允许剪切比例。如果值为NO，剪切比例将不会被重置。（固定预设剪切比例）
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditCropCanAspectRatioAttributeName;
/**
 自定义剪切比例。将会完全重写剪切比例，如需修改显示比例的名称可在LFImagePickerController.strings修改。
 @[
    [TFY_ExtraAspectRatio extraAspectRatioWithWidth:9 andHeight:16],
    [TFY_ExtraAspectRatio extraAspectRatioWithWidth:2 andHeight:3],
 ].
 */
UIKIT_EXTERN TFYPhotoEditOperationStringKey const TFYPhotoEditCropExtraAspectRatioAttributeName;

/************************ Attributes ************************/

typedef NS_ENUM(NSUInteger, TFYPhotoEditOperationSubType) {
    
    /** TFYPhotoEditOperationType_draw && TFYPhotoEditDrawColorAttributeName */
    
    TFYPhotoEditOperationSubTypeDrawWhiteColor = 1,
    TFYPhotoEditOperationSubTypeDrawBlackColor,
    TFYPhotoEditOperationSubTypeDrawRedColor,
    TFYPhotoEditOperationSubTypeDrawLightYellowColor,
    TFYPhotoEditOperationSubTypeDrawYellowColor,
    TFYPhotoEditOperationSubTypeDrawLightGreenColor,
    TFYPhotoEditOperationSubTypeDrawGreenColor,
    TFYPhotoEditOperationSubTypeDrawAzureColor,
    TFYPhotoEditOperationSubTypeDrawRoyalBlueColor,
    TFYPhotoEditOperationSubTypeDrawBlueColor,
    TFYPhotoEditOperationSubTypeDrawPurpleColor,
    TFYPhotoEditOperationSubTypeDrawLightPinkColor,
    TFYPhotoEditOperationSubTypeDrawVioletRedColor,
    TFYPhotoEditOperationSubTypeDrawPinkColor,
    
    /** TFYPhotoEditOperationType_draw && TFYPhotoEditDrawBrushAttributeName */
    TFYPhotoEditOperationSubTypeDrawPaintBrush = 50,
    TFYPhotoEditOperationSubTypeDrawHighlightBrush,
    TFYPhotoEditOperationSubTypeDrawChalkBrush,
    TFYPhotoEditOperationSubTypeDrawFluorescentBrush,
    TFYPhotoEditOperationSubTypeDrawStampAnimalBrush,
    TFYPhotoEditOperationSubTypeDrawStampFruitBrush,
    TFYPhotoEditOperationSubTypeDrawStampHeartBrush,
    
    /** TFYPhotoEditOperationType_text && TFYPhotoEditTextColorAttributeName */
    
    TFYPhotoEditOperationSubTypeTextWhiteColor = 100,
    TFYPhotoEditOperationSubTypeTextBlackColor,
    TFYPhotoEditOperationSubTypeTextRedColor,
    TFYPhotoEditOperationSubTypeTextLightYellowColor,
    TFYPhotoEditOperationSubTypeTextYellowColor,
    TFYPhotoEditOperationSubTypeTextLightGreenColor,
    TFYPhotoEditOperationSubTypeTextGreenColor,
    TFYPhotoEditOperationSubTypeTextAzureColor,
    TFYPhotoEditOperationSubTypeTextRoyalBlueColor,
    TFYPhotoEditOperationSubTypeTextBlueColor,
    TFYPhotoEditOperationSubTypeTextPurpleColor,
    TFYPhotoEditOperationSubTypeTextLightPinkColor,
    TFYPhotoEditOperationSubTypeTextVioletRedColor,
    TFYPhotoEditOperationSubTypeTextPinkColor,
    
    /** TFYPhotoEditOperationType_splash && TFYPhotoEditSplashAttributeName */
    
    TFYPhotoEditOperationSubTypeSplashMosaic = 300,
    TFYPhotoEditOperationSubTypeSplashBlurry,
    TFYPhotoEditOperationSubTypeSplashPaintbrush,
    
    /** TFYPhotoEditOperationType_filter && TFYPhotoEditFilterAttributeName */
    
    TFYPhotoEditOperationSubTypeLinearCurveFilter = 400,
    TFYPhotoEditOperationSubTypeChromeFilter,
    TFYPhotoEditOperationSubTypeFadeFilter,
    TFYPhotoEditOperationSubTypeInstantFilter,
    TFYPhotoEditOperationSubTypeMonoFilter,
    TFYPhotoEditOperationSubTypeNoirFilter,
    TFYPhotoEditOperationSubTypeProcessFilter,
    TFYPhotoEditOperationSubTypeTonalFilter,
    TFYPhotoEditOperationSubTypeTransferFilter,
    TFYPhotoEditOperationSubTypeCurveLinearFilter,
    TFYPhotoEditOperationSubTypeInvertFilter,
    TFYPhotoEditOperationSubTypeMonochromeFilter,
    
    /** TFYPhotoEditOperationType_crop && TFYPhotoEditCropAspectRatioAttributeName */
    
    TFYPhotoEditOperationSubTypeCropAspectRatioOriginal = 500,
    TFYPhotoEditOperationSubTypeCropAspectRatio1x1,
    TFYPhotoEditOperationSubTypeCropAspectRatio3x2,
    TFYPhotoEditOperationSubTypeCropAspectRatio4x3,
    TFYPhotoEditOperationSubTypeCropAspectRatio5x3,
    TFYPhotoEditOperationSubTypeCropAspectRatio15x9,
    TFYPhotoEditOperationSubTypeCropAspectRatio16x9,
    TFYPhotoEditOperationSubTypeCropAspectRatio16x10,
};

@protocol TFYPhotoEditingControllerDelegate <NSObject>

- (void)picker_PhotoEditingControllerDidCancel:(TFY_PhotoEditingController *)photoEditingVC;
- (void)picker_PhotoEditingController:(TFY_PhotoEditingController *)photoEditingVC didFinishPhotoEdit:(TFY_PhotoEdit *)photoEdit;

@end

@interface TFY_PhotoEditingController : TFY_BaseEditingController
/**
 设置编辑图片->重新初始化
 Set edit photo -> init
 */
@property (nonatomic, strong) UIImage *editImage;

/**
 对GIF而言。editImage的每帧持续间隔是平均分配的，durations的每帧持续间隔是真实的。同时也会影响到最终生成的GIF数据。
 */
- (void)setEditImage:(UIImage *)editImage durations:(nullable NSArray<NSNumber *> *)durations;

/**
 设置编辑对象->重新编辑
 Set edit object -> re-edit
 */
- (void)setPhotoEdit:(TFY_PhotoEdit *)photoEdit;

/**
 设置操作类型
 The type of operation.
 default is TFYPhotoEditOperationType_All
 */
@property (nonatomic, assign) TFYPhotoEditOperationType operationType;
/**
 设置默认的操作类型，可以选择最多2种操作，优先级以operationType类型为准。
 1、LFPhotoEditOperationType_crop优于所有类型。所有类型可与LFPhotoEditOperationType_crop搭配；
 2、LFPhotoEditOperationType_crop以外的其它类型搭配以优先级排序仅显示1种。
 ps:当operationType 与 defaultOperationType 只有LFPhotoEditOperationType_crop的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 */
@property (nonatomic, assign) TFYPhotoEditOperationType defaultOperationType;
/**
 操作属性设置，根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
*/
@property (nonatomic, strong) NSDictionary<TFYPhotoEditOperationStringKey, id> *operationAttrs;

/** 代理 */
@property (nonatomic, weak) id<TFYPhotoEditingControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
