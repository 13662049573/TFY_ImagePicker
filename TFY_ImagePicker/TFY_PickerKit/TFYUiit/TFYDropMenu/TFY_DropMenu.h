//
//  TFY_DropMenu.h
//  WonderfulZhiKang
//
//  Created by 田风有 on 2022/12/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFY_DropItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFY_DropMenu : NSObject
/** 自动收起 */
+ (void)setAutoDismiss:(BOOL)isAutoDismiss;
/** 是否显示 */
+ (BOOL)isOnShow;
/** 背景颜色 */
+ (void)setBackgroundColor:(UIColor *)color;
/** 显示方向 */
+ (void)setDirection:(TFYDropMainMenuDirection)direction;

#pragma mark - function
+ (void)showInView:(UIView *)view items:(NSArray <id <TFY_DropItemProtocol>>*)items;
+ (void)showFromPoint:(CGPoint)point items:(NSArray <id <TFY_DropItemProtocol>>*)items;

+ (void)dismiss;
@end

NS_ASSUME_NONNULL_END
