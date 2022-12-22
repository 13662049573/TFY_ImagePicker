//
//  NSObject+picker.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (picker)

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// views 需要提示的目标视图集合。
/// tipsArr 提示内容集合
- (void)picker_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// views 需要提示的目标视图集合。
/// tipsArr 提示内容集合
/// times 提示次数
- (void)picker_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// rects 需要提示的目标位置集合
/// tipsArr 提示内容集合
- (void)picker_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

/// 弹出提示界面
/// view 在某个视图上。建议在keywindow。
/// rects 需要提示的目标位置集合
/// tipsArr 提示内容集合
/// times 提示次数
- (void)picker_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

@end

NS_ASSUME_NONNULL_END
