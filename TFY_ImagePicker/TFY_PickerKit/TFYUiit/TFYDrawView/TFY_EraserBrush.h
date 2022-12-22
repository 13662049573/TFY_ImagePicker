//
//  TFY_EraserBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_PaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_EraserBrush : TFY_PaintBrush
/**
异步加载橡皮擦画笔

mage 图层展示的图片
canvasSize 画布大小
useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
complete 回调状态(成功后可以直接使用[[LFBlurryBrush alloc] init]初始化画笔)
*/
+ (void)loadEraserImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;

/**
橡皮擦画笔缓存

是否存在缓存
*/
+ (BOOL)eraserBrushCache;

/**
 创建橡皮擦画笔，创建前必须调用“异步加载橡皮擦画笔”👆
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
