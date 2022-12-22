//
//  TFY_SmearBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_Brush.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_SmearBrush : TFY_Brush
/**
 异步加载涂抹画笔

 image 图层展示的图片
 canvasSize 画布大小
 useCache 是否使用缓存。如果image与canvasSize固定，建议使用缓存。
 complete 回调状态(成功后可以直接使用[[LFSmearBrush alloc] init]初始化画笔)
 */
+ (void)loadBrushImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete;


/**
 涂抹画笔缓存

 是否存在缓存
 */
+ (BOOL)smearBrushCache;


/**
 创建涂抹画笔，创建前必须调用“异步加载涂抹画笔”👆

 name 涂抹图片
 */
- (instancetype)initWithImageName:(NSString *)name;


@end

NS_ASSUME_NONNULL_END
