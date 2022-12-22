//
//  TFY_EditingProtocol.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import "TFY_PhotoEditDelegate.h"
#import "TFY_StickerItem.h"
#import "TFY_MediaEditingType.h"
#import "TFYDrawView.h"


@class TFY_Brush, TFY_DrawView, TFY_StickerView, TFY_DataFilterImageView, TFY_DataFilterVideoView;
@protocol TFY_EditingProtocol, TFY_FilterDataProtocol;

NS_ASSUME_NONNULL_BEGIN

// 实现TFY_EditingProtocol的所有非必要方法。
@interface UIView (TFY_EditingProtocol)

// 协议执行者
@property (nonatomic, weak) UIView <TFY_EditingProtocol>* picker_protocolxecutor;

/** 绘画 */
@property (nonatomic, weak) TFY_DrawView *picker_drawView;
/** 贴图 */
@property (nonatomic, weak) TFY_StickerView *picker_stickerView;
/** 模糊（马赛克、高斯模糊、涂抹） */
@property (nonatomic, weak) TFY_DrawView *picker_splashView;

/** 展示 */
@property (nonatomic, weak) id<TFY_FilterDataProtocol> picker_displayView;

- (void)clearProtocolxecutor;

@end

@protocol TFY_EditingProtocol <NSObject>

/** =====================数据===================== */

/** 数据 */
@property (nonatomic, strong, nullable) NSDictionary *photoEditData;

@optional
/** =====================设置项===================== */
/** 代理 */
@property (nonatomic, weak) id<TFY_PhotoEditDelegate> editDelegate;

/** 禁用其他功能 */
- (void)photoEditEnable:(BOOL)enable;

/** =====================绘画功能===================== */

/** 启用绘画功能 */
@property (nonatomic, assign) BOOL drawEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL drawCanUndo;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 撤销绘画 */
- (void)drawUndo;
/** 设置绘画画笔 */
- (void)setDrawBrush:(TFY_Brush *)brush;
/** 设置绘画颜色 */
- (void)setDrawColor:(UIColor *)color;
/** 设置绘画线粗 */
- (void)setDrawLineWidth:(CGFloat)lineWidth;

/** =====================贴图功能===================== */
/** 贴图启用 */
@property (nonatomic, readonly) BOOL stickerEnable;
/** 取消激活贴图 */
- (void)stickerDeactivated;
/** 激活选中的贴图 */
- (void)activeSelectStickerView;
/** 删除选中贴图 */
- (void)removeSelectStickerView;
/** 屏幕缩放率 */
@property (nonatomic, assign) CGFloat screenScale;
/** 最小缩放率 */
@property (nonatomic, assign) CGFloat stickerMinScale;
/** 最大缩放率 */
@property (nonatomic, assign) CGFloat stickerMaxScale;

/** 创建贴图 */
- (void)createSticker:(TFY_StickerItem *)item;
/** 获取选中贴图的内容 */
- (TFY_StickerItem *)getSelectSticker;
/** 更改选中贴图内容 */
- (void)changeSelectSticker:(TFY_StickerItem *)item;

/** =====================模糊功能===================== */

/** 启用模糊功能 */
@property (nonatomic, assign) BOOL splashEnable;
/** 是否可撤销 */
@property (nonatomic, readonly) BOOL splashCanUndo;
/** 正在模糊 */
@property (nonatomic, readonly) BOOL isSplashing;
/** 撤销模糊 */
- (void)splashUndo;

/** 设置模糊类型 */
@property (nonatomic, assign) TFYSplashStateType splashStateType;

/** 设置模糊线粗 */
- (void)setSplashLineWidth:(CGFloat)lineWidth;

/** =====================滤镜功能===================== */
/** 滤镜类型 */
- (void)changeFilterType:(NSInteger)cmType;
/** 当前使用滤镜类型 */
- (NSInteger)getFilterType;
/** 获取滤镜图片 */
- (UIImage *)getFilterImage;

@end


NS_ASSUME_NONNULL_END
