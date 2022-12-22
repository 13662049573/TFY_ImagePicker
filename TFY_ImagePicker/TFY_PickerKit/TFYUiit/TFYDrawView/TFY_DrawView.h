//
//  TFY_DrawView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import "TFY_Brush.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DrawView : UIView

/** 画笔 */
@property (nonatomic, strong) TFY_Brush *brush;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 图层数量 */
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, copy) void(^drawBegan)(void);
@property (nonatomic, copy) void(^drawEnded)(void);

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 是否可撤销 */
- (BOOL)canUndo;
//撤销
- (void)undo;

@end

NS_ASSUME_NONNULL_END
