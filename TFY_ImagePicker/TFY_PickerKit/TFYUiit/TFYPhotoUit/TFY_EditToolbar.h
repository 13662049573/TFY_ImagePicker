//
//  TFY_EditToolbar.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import <UIKit/UIKit.h>
#import "TFY_Brush.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN CGFloat kToolbar_MainHeight;
UIKIT_EXTERN CGFloat kToolbar_SubHeight;
UIKIT_EXTERN NSUInteger kToolbar_MaxItems;

typedef NS_ENUM(NSUInteger, TFYEditToolbarType) {
    /** 绘画 */
    TFYEditToolbarType_draw = 1 << 0,
    /** 贴图 */
    TFYEditToolbarType_sticker = 1 << 1,
    /** 文本 */
    TFYEditToolbarType_text = 1 << 2,
    /** 模糊 */
    TFYEditToolbarType_splash = 1 << 3,
    /** 修剪 */
    TFYEditToolbarType_crop = 1 << 4,
    /** 音频 */
    TFYEditToolbarType_audio = 1 << 5,
    /** 剪辑 */
    TFYEditToolbarType_clip = 1 << 6,
    /** 滤镜 */
    TFYEditToolbarType_filter = 1 << 7,
    /** 速率 */
    TFYEditToolbarType_rate = 1 << 8,
    /** 所有 */
    TFYEditToolbarType_All = ~0UL,
};

typedef NS_ENUM(NSUInteger, TFYEditToolbarBrushType) {
    /** 画笔 */
    TFYEditToolbarBrushTypePaint = 0,
    /** 双色笔 */
    TFYEditToolbarBrushTypeHighlight,
    /** 粉笔 */
    TFYEditToolbarBrushTypeChalk,
    /** 荧光笔 */
    TFYEditToolbarBrushTypeFluorescent,
    /** 图章 */
    TFYEditToolbarBrushTypeStamp,
    /** 橡皮擦 */
    TFYEditToolbarBrushTypeEraser,
};

typedef NS_ENUM(NSUInteger, TFYEditToolbarStampBrushType) {
    /** 动物 */
    TFYEditToolbarStampBrushTypeAnimal,
    /** 水果 */
    TFYEditToolbarStampBrushTypeFruit,
    /** 心 */
    TFYEditToolbarStampBrushTypeHeart,
};

@class TFY_EditToolbar;

@protocol TFYEditToolbarDelegate <NSObject>

/**
 主菜单点击事件

 editToolbar self
 index 坐标（第几个按钮）
 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar mainDidSelectAtIndex:(NSUInteger)index;
/** 二级菜单点击事件-撤销 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar subDidRevokeAtIndex:(NSUInteger)index;
/** 二级菜单点击事件-按钮 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar subDidSelectAtIndex:(NSIndexPath *)indexPath;
/** 撤销允许权限获取 */
- (BOOL)picker_editToolbar:(TFY_EditToolbar *)editToolbar canRevokeAtIndex:(NSUInteger)index;
/** 二级菜单滑动事件-绘画 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar drawColorDidChange:(UIColor *)color;
/** 二级菜单笔刷事件-绘画 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar drawBrushDidChange:(TFY_Brush *)brush;
@optional
/** 二级菜单滑动事件-速率 */
- (void)picker_editToolbar:(TFY_EditToolbar *)editToolbar rateDidChange:(float)value;
@end


@interface TFY_EditToolbar : UIView

- (instancetype)initWithType:(TFYEditToolbarType)type;

@property (nonatomic, weak) id<TFYEditToolbarDelegate> delegate;

@property (nonatomic, readonly) NSUInteger items;

/** 播放速率 */
@property (nonatomic, assign) float rate;

/** 当前激活主菜单 return -1 没有激活 */
- (NSUInteger)mainSelectAtIndex;

/** 允许撤销 */
- (void)setRevokeAtIndex:(NSUInteger)index;

/** 设置绘画拾色器默认颜色（会触发代理） */
- (void)setDrawSliderColorAtIndex:(NSUInteger)index;
/** 设置绘画拾色器默认笔刷（会触发代理） */
- (void)setDrawBrushAtIndex:(TFYEditToolbarBrushType)index subIndex:(TFYEditToolbarStampBrushType)subIndex;
/** 设置默认模糊类型（会触发代理） */
- (void)setSplashIndex:(NSUInteger)index;
/** 设置画笔等待状态 */
- (void)setDrawBrushWait:(BOOL)isWait;
/** 设置模糊等待状态 */
- (void)setSplashWait:(BOOL)isWait index:(NSUInteger)index;

/** 选择主菜单的功能类型（会触发代理）TFYEditToolbarType */
- (void)selectMainMenuIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
