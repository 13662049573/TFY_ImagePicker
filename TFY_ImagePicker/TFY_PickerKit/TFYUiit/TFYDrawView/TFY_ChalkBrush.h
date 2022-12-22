//
//  TFY_ChalkBrush.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import "TFY_PaintBrush.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_ChalkBrush : TFY_PaintBrush
/// 创建粉笔画笔
- (instancetype)initWithImageName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
