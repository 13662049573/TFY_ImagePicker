//
//  TFY_BlurryBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/20.
//

#import "TFY_PaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_BlurryBrush : TFY_PaintBrush
/**
 异步加载模糊画笔

 图层展示的图片
 radius 模糊范围系数，越大越模糊。建议5.0
 canvasSize 画布大小
 useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 complete 回调状态(成功后可以直接使用[[LFBlurryBrush alloc] init]初始化画笔)
 */
+ (void)loadBrushImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;


/**
 模糊画笔缓存

 是否存在缓存
 */
+ (BOOL)blurryBrushCache;

/**
 创建模糊画笔，创建前必须调用“异步加载模糊画笔”👆
 */
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
