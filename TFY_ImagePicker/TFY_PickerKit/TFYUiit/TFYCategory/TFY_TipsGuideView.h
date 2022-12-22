//
//  TFY_TipsGuideView.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFY_TipsGuideView : UIView

@property (nonatomic, copy, nullable) void (^didShowTips)(NSInteger index);
@property (nonatomic, copy, nullable) void (^completion)(void);

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// views 需要提示的目标视图集合。
/// tipsArr 提示内容集合
- (void)showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// rects 需要提示的目标位置集合
/// tipsArr 提示内容集合
- (void)showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

/// 销毁提示视图
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
