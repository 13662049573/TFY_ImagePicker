//
//  TFY_MosaicBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_PaintBrush.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TFY_MosaicBrush : TFY_PaintBrush
/**
 异步加载马赛克画笔

 image 图层展示的图片
 scale 马赛克大小系数。建议15.0
 canvasSize 画布大小
 useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 complete 回调状态(成功后可以直接使用[[LFMosaicBrush alloc] init]初始化画笔)
 */
+ (void)loadBrushImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;

/**
 马赛克画笔缓存

 是否存在缓存
 */
+ (BOOL)mosaicBrushCache;

/**
 创建马赛克画笔，创建前必须调用“异步加载马赛克画笔”👆
 */
- (instancetype)init;


@end

NS_ASSUME_NONNULL_END
