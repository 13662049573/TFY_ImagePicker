//
//  TFY_StickerView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>
#import "TFY_PickerText.h"
#import "TFY_StickerItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_StickerView : UIView

/** 取消当前激活的贴图 */
+ (void)stickerViewDeactivated;

/** 激活选中的贴图 */
- (void)activeSelectStickerView;
/** 删除选中贴图 */
- (void)removeSelectStickerView;

/** 获取选中贴图的内容 */
- (TFY_StickerItem *)getSelectStickerItem;

/** 更改选中贴图内容 */
- (void)changeSelectStickerItem:(TFY_StickerItem *)item;

/** create sticker */
- (void)createStickerItem:(TFY_StickerItem *)item;

/** 最小缩放率 默认0.3 */
@property (nonatomic, assign) CGFloat minScale;
/** 最大缩放率 默认3.0 */
@property (nonatomic, assign) CGFloat maxScale;
/** 贴图数量 */
@property (nonatomic, readonly) NSUInteger count;

/** 显示界面的缩放率，例如在UIScrollView上显示，scrollView放大了5倍，movingView的视图控件会显得较大，这个属性是适配当前屏幕的比例调整控件大小 */
@property (nonatomic, assign) CGFloat screenScale;

/** 是否启用（移动或点击） */
@property (nonatomic, readonly, getter=isEnable) BOOL enable;

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 点击回调视图 */
@property (nonatomic, copy, nullable) void(^tapEnded)(TFY_StickerItem *item, BOOL isActive);
/** 视图开始移动 */
@property (nonatomic, copy, nullable) void(^movingBegan)(TFY_StickerItem *item);
/** 视图结束移动 */
@property (nonatomic, copy, nullable) void(^movingEnded)(TFY_StickerItem *item);
/** 视图超出屏幕后的返回位置 */
@property (nonatomic, copy, nullable) BOOL(^moveCenter)(CGRect rect);

@end

NS_ASSUME_NONNULL_END
